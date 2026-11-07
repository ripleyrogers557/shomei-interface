/// Shomei price-feed interface.
///
/// This package exists only so other Move packages can depend on and call
/// Shomei's published price-feed contract. It contains the read-only,
/// consumer-facing surface: struct declarations and function signatures,
/// with no real implementation.
///
/// Every function body below is unreachable at runtime. This package's
/// Move.toml sets `published-at` to Shomei's live on-chain address, so any
/// package that depends on it links directly against the real, deployed
/// module — these local bodies exist only so this package type-checks and
/// compiles on its own.
///
/// This interface deliberately omits feed creation, reference attachment,
/// price posting, and key-rotation/admin functions: those are gated by
/// capabilities only Shomei's own operators hold, so no external caller
/// needs their signatures to integrate a price feed.
module shomei::price_feed {
    use sui::clock::Clock;

    /// Never actually raised — every function here is a stub that is
    /// unreachable once a dependent links against the real published module.
    const EInterfaceOnly: u64 = 0;

    /// A single signed price.
    /// value = (negative ? -1 : 1) * mantissa * 10 ^ ((expo_negative ? 1 : -1) * expo)
    public struct PriceValue has store, copy, drop {
        mantissa: u64,
        negative: bool,
        expo: u64,
        expo_negative: bool,
        conf: u64,
        publish_time_ms: u64,
    }

    public fun price_value_mantissa(price: &PriceValue): u64 { price.mantissa }
    public fun price_value_is_negative(price: &PriceValue): bool { price.negative }
    public fun price_value_expo(price: &PriceValue): u64 { price.expo }
    public fun price_value_expo_is_negative(price: &PriceValue): bool { price.expo_negative }
    public fun price_value_conf(price: &PriceValue): u64 { price.conf }
    public fun price_value_publish_time_ms(price: &PriceValue): u64 { price.publish_time_ms }

    /// A shared, on-chain price feed object. Fields are private to the real
    /// module — read them through the accessor functions below.
    public struct PriceFeed has key {
        id: UID,
    }

    public fun symbol(_feed: &PriceFeed): vector<u8> { abort EInterfaceOnly }
    public fun price(_feed: &PriceFeed): &PriceValue { abort EInterfaceOnly }
    public fun trusted_pubkey(_feed: &PriceFeed): vector<u8> { abort EInterfaceOnly }
    public fun has_reference(_feed: &PriceFeed): bool { abort EInterfaceOnly }
    public fun is_retired(_feed: &PriceFeed): bool { abort EInterfaceOnly }
    public fun version(_feed: &PriceFeed): u64 { abort EInterfaceOnly }
    public fun reference_price(_feed: &PriceFeed): &PriceValue { abort EInterfaceOnly }
    public fun reference_trusted_pubkey(_feed: &PriceFeed): vector<u8> { abort EInterfaceOnly }
    public fun max_deviation_bps(_feed: &PriceFeed): u64 { abort EInterfaceOnly }
    public fun max_reference_staleness_ms(_feed: &PriceFeed): u64 { abort EInterfaceOnly }
    public fun publish_fee(_feed: &PriceFeed): u64 { abort EInterfaceOnly }

    public fun assert_price_not_older_than(_feed: &PriceFeed, _max_age_ms: u64, _clock: &Clock) {
        abort EInterfaceOnly
    }

    public fun get_price_no_older_than(_feed: &PriceFeed, _max_age_ms: u64, _clock: &Clock): PriceValue {
        abort EInterfaceOnly
    }

    public fun price_and_ema(_feed: &PriceFeed): (&PriceValue, &PriceValue) { abort EInterfaceOnly }

    public fun get_price_and_ema_no_older_than(
        _feed: &PriceFeed, _max_age_ms: u64, _clock: &Clock,
    ): (PriceValue, PriceValue) {
        abort EInterfaceOnly
    }
}
