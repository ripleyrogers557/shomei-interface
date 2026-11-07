# shomei-interface

The public Move interface for [Shomei](https://shomei.dev), a price oracle on Sui.

This package lets other Move packages depend on and call Shomei's price-feed contract. It contains **only** the read-only, consumer-facing surface — struct declarations and function signatures, with no real implementation. Full contract source is maintained in a separate, private repository.

Every function body here is unreachable at runtime: this package's `Move.toml` sets `published-at` to Shomei's live on-chain address, so any package depending on it links directly against the real, deployed module. The bodies in this repo exist only so the package type-checks and compiles on its own — they are never actually executed.

This interface deliberately omits feed creation, reference attachment, price posting, and key-rotation/admin functions — those are gated by capabilities only Shomei's own operators hold, so no external integrator needs their signatures.

## Using it

```toml
[dependencies]
shomei = { git = "https://github.com/ripleyrogers557/shomei-interface.git", rev = "main" }

[addresses]
shomei = "0x82b20f522e8387e4acf69be8fe10f53ec82afca1fa05b8c504609ebc54bf97b2"
```

Pin `rev` to a commit hash rather than `main` for a reproducible build.

```move
use shomei::price_feed::{Self, PriceFeed};

public fun read_price(feed: &PriceFeed, clock: &Clock): u64 {
    let price = price_feed::get_price_no_older_than(feed, 60_000, clock);
    price_feed::price_value_mantissa(&price)
}
```

## Deployed package

- **Testnet:** `0x82b20f522e8387e4acf69be8fe10f53ec82afca1fa05b8c504609ebc54bf97b2` ([view on Sui Explorer](https://suiscan.xyz/testnet/object/0x82b20f522e8387e4acf69be8fe10f53ec82afca1fa05b8c504609ebc54bf97b2))
- **Mainnet:** not yet deployed.

Full SDK (for reading and publishing prices from TypeScript, no Move required): [`@shomei_orcl/sui-sdk`](https://www.npmjs.com/package/@shomei_orcl/sui-sdk).

## License

MIT
