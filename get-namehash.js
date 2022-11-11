const namehash = require("eth-ens-namehash");
let hash = namehash.hash("addr.reverse");
let input = "s💝s.eth";
console.log(hash);
// '0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f'

// Also supports normalizing strings to ENS compatibility:
console.log(namehash.normalize(input));
