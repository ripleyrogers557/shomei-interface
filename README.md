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
use sui::clock::Clock;
use shomei::price_feed::{Self, PriceFeed};

const MAX_PRICE_AGE_MS: u64 = 60_000; // 1 minute

/// Scales `amount` by this feed's current price. Move has no floating
/// point, so this is fixed-point arithmetic:
/// value = mantissa * 10^((expo_negative ? 1 : -1) * expo)
public fun scale_by_price(feed: &PriceFeed, clock: &Clock, amount: u64): u64 {
    let price = price_feed::get_price_no_older_than(feed, MAX_PRICE_AGE_MS, clock);
    assert!(!price_feed::price_value_is_negative(&price), 0); // Shomei's spot prices are never negative

    let mantissa = (price_feed::price_value_mantissa(&price) as u128);
    let expo = price_feed::price_value_expo(&price);
    let product = (amount as u128) * mantissa;

    let result = if (price_feed::price_value_expo_is_negative(&price)) {
        product * pow10(expo)
    } else {
        product / pow10(expo)
    };
    (result as u64)
}

fun pow10(exp: u64): u128 {
    let mut result: u128 = 1;
    let mut i = 0;
    while (i < exp) { result = result * 10; i = i + 1; };
    result
}
```

`get_price_no_older_than` aborts if the price is older than `MAX_PRICE_AGE_MS`, so staleness never needs a separate check. Widen to `u128` before multiplying — a full-width `u64` mantissa times a large amount overflows `u64` easily.

## Deployed package

- **Testnet:** `0x82b20f522e8387e4acf69be8fe10f53ec82afca1fa05b8c504609ebc54bf97b2` ([view on Sui Explorer](https://suiscan.xyz/testnet/object/0x82b20f522e8387e4acf69be8fe10f53ec82afca1fa05b8c504609ebc54bf97b2))
- **Mainnet:** not yet deployed.

Full SDK (for reading and publishing prices from TypeScript, no Move required): [`@shomei_orcl/sui-sdk`](https://www.npmjs.com/package/@shomei_orcl/sui-sdk).

## License

MIT
