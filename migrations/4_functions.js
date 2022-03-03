const functions = artifacts.require("functions");

module.exports = function (deployer) {
  deployer.deploy(functions);
};
