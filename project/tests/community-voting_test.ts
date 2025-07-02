import { Clarinet, Tx, Chain, Account } from "@clarinet/test";

Clarinet.test({
  name: "Can create a new proposal",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let block = chain.mineBlock([
      Tx.contractCall("community-voting", "create-proposal", [
        Buffer.from("Test proposal"),
        "u100"
      ], deployer.address),
    ]);

    block.receipts[0].result.expectOk().expectUint(0);
  },
});
