import chai from 'chai'
import {
  MockProvider,
  deployContract,
  solidity
} from 'ethereum-waffle'
import * as Rollup from '../build/Rollup.json'
import * as ethers from 'ethers'

chai.use(solidity)
chai.use(require('chai-as-promised'))
const { expect } = chai

describe('Rollup', () => {
  let wallets = new MockProvider().getWallets()
  let wallet = wallets[0]
  let rollup: any
  const root = ethers.utils.keccak256(
    ethers.utils.arrayify(ethers.constants.HashZero)
  )

  beforeEach(async () => {
    rollup = await deployContract(wallet, Rollup, [
      wallet.address
    ])
  })

  describe('submitRoot', () => {
    it('succeed to submit root', async () => {
      await expect(rollup.submitRoot(1, root, ['0x00'])).to.emit(
        rollup,
        'BlockSubmitted'
      )
    })
  })

})