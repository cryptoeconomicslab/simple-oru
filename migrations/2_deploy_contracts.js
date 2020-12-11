const Rollup = artifacts.require('Rollup.sol')
const SwapStateTransition = artifacts.require('SwapStateTransition')

module.exports = function(deployer) {
  deployer
    .deploy(Rollup)
    .then(() => deployer.deploy(SwapStateTransition))
}
