pragma solidity >=0.8.4;

import "./PriceOracle.sol";
import "./BaseRegistrarImplementation.sol";
import "./StringUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../resolvers/Resolver.sol";

/**
 * @dev A registrar controller for registering and renewing names at fixed cost.
 */
contract ETHRegistrarController is Ownable {
    using StringUtils for *;

    uint constant public MIN_REGISTRATION_DURATION = 28 days;

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private COMMITMENT_CONTROLLER_ID = bytes4(
        keccak256("rentPrice(string,uint256)") ^
        keccak256("available(string)") ^
        keccak256("makeCommitment(string,address,bytes32)") ^
        keccak256("commit(bytes32)") ^
        keccak256("register(string,address,uint256,bytes32)") ^
        keccak256("renew(string,uint256)")
    );

    bytes4 constant private COMMITMENT_WITH_CONFIG_CONTROLLER_ID = bytes4(
        keccak256("registerWithConfig(string,address,uint256,bytes32,address,address)") ^
        keccak256("makeCommitmentWithConfig(string,address,bytes32,address,address)")
    );

    BaseRegistrarImplementation base;
    PriceOracle prices;
    uint public minCommitmentAge;
    uint public maxCommitmentAge;

    mapping(bytes32=>uint) public commitments;

    event NameRegistered(string name, bytes32 indexed label, address indexed owner, uint cost, uint expires);
    event NameRenewed(string name, bytes32 indexed label, uint cost, uint expires);
    event NewPriceOracle(address indexed oracle);

    constructor(BaseRegistrarImplementation _base, PriceOracle _prices, uint _minCommitmentAge, uint _maxCommitmentAge) public {
        require(_maxCommitmentAge > _minCommitmentAge);

        base = _base;
        prices = _prices;
        minCommitmentAge = _minCommitmentAge;
        maxCommitmentAge = _maxCommitmentAge;
    }
    
    function rentPrice(string memory name, uint duration) view public returns(uint) {
        bytes32 hash = keccak256(bytes(name));
        return prices.price(name, base.nameExpires(uint256(hash)), duration);
    }

    function valid(string memory name) public pure returns(bool) {
        return name.strlen() >= 3;
    }
    
    function available(string memory name) public view returns(bool) {
        bytes32 label = keccak256(bytes(name));
        return valid(name) && base.available(uint256(label));
    }

    function makeCommitment(string memory name, address owner, bytes32 secret) pure public returns(bytes32) {
        return makeCommitmentWithConfig(name, owner, secret, address(0), address(0));
    }
    /**
     * @dev 第一阶段：生成commitment
     */
    function makeCommitmentWithConfig(string memory name, address owner, bytes32 secret, address resolver, address addr) pure public returns(bytes32) {
        // 根据子域名生成label
        bytes32 label = keccak256(bytes(name));
        if (resolver == address(0) && addr == address(0)) {
            return keccak256(abi.encodePacked(label, owner, secret));
        }
        require(resolver != address(0));
        // 根据label、owner、resolver、addr、seret生成commitment
        return keccak256(abi.encodePacked(label, owner, resolver, addr, secret));
    }
    /**
     * @dev 第一阶段：提交commitment
     */
    function commit(bytes32 commitment) public {
        // 如果已经存在commitment，需要确保超过了24小时有效期
        require(commitments[commitment] + maxCommitmentAge < block.timestamp);
        // 设置commitment时间戳
        commitments[commitment] = block.timestamp;
    }

    function register(string calldata name, address owner, uint duration, bytes32 secret) external payable {
      registerWithConfig(name, owner, duration, secret, address(0), address(0));
    }
    /**
     * @dev 第二阶段：注册
     */
    function registerWithConfig(string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) public payable {
        // 获取commitment
        bytes32 commitment = makeCommitmentWithConfig(name, owner, secret, resolver, addr);
        // 消费commitment，返回域名价格
        uint cost = _consumeCommitment(name, duration, commitment);

        bytes32 label = keccak256(bytes(name));
        // 字节转换为uint256
        uint256 tokenId = uint256(label);

        uint expires;
        // 自定义解析器
        if(resolver != address(0)) {
            // 到注册器去注册该域名，先将子域名的所有权给controller合约，给controller权限去设置解析器
            expires = base.register(tokenId, address(this), duration);

            // 域名(子域名.TLD)的hash值
            bytes32 nodehash = keccak256(abi.encodePacked(base.baseNode(), label));

            // 只有域名所有者才能设置解析器，去注册表设置解析器
            base.ens().setResolver(nodehash, resolver);

            // 设置解析器关联的钱包地址，用于正向解析，如test.eth -> 0x....
            if (addr != address(0)) {
                Resolver(resolver).setAddr(nodehash, addr);
            }
            // Now transfer full ownership to the expeceted owner
            base.reclaim(tokenId, owner);
            base.transferFrom(address(this), owner, tokenId);
        } else {
            require(addr == address(0));
            expires = base.register(tokenId, owner, duration);
        }

        emit NameRegistered(name, label, owner, cost, expires);

        // 退还额外的开销
        if(msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }
    /**
     * @dev 延长域名
     */
    function renew(string calldata name, uint duration) external payable {
        uint cost = rentPrice(name, duration);
        require(msg.value >= cost);

        bytes32 label = keccak256(bytes(name));
        uint expires = base.renew(uint256(label), duration);

        if(msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        emit NameRenewed(name, label, cost, expires);
    }
    // 设置PriceOracle
    function setPriceOracle(PriceOracle _prices) public onlyOwner {
        prices = _prices;
        emit NewPriceOracle(address(prices));
    }

    function setCommitmentAges(uint _minCommitmentAge, uint _maxCommitmentAge) public onlyOwner {
        minCommitmentAge = _minCommitmentAge;
        maxCommitmentAge = _maxCommitmentAge;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);        
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == COMMITMENT_CONTROLLER_ID ||
               interfaceID == COMMITMENT_WITH_CONFIG_CONTROLLER_ID;
    }
    /**
     * @dev 消费commitment
     */
    function _consumeCommitment(string memory name, uint duration, bytes32 commitment) internal returns (uint256) {
        // commitment需要等待1分钟才能消费
        require(commitments[commitment] + minCommitmentAge <= block.timestamp);
        // commitment需要在24小时内消费
        require(commitments[commitment] + maxCommitmentAge > block.timestamp);
        // 域名有效性校验:长度大于等于3、未注册或者超出90天保留期
        require(available(name));
        // 删除该commitment
        delete(commitments[commitment]);
        // 域名价格=域名单价*域名时长+附加费用(0)
        uint cost = rentPrice(name, duration);
        // 域名时长至少28天
        require(duration >= MIN_REGISTRATION_DURATION);
        // msg.value大于cost
        require(msg.value >= cost);

        return cost;
    }
}
