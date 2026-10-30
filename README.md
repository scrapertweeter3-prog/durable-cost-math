# DurableCostMath

Buy-it-for-life cost math for Swift: price a purchase by what it costs per
year, per decade, and per use, not by its sticker.

- `annualCost` - price over the years the item actually lasts
- `costPerDecade` - the ten-year number two options should be compared on
- `costPerUse` - price divided by every use over the item's life
- `premiumBreakEvenYears` - the lifespan a premium buy must reach to win
- `priceAtParity` - the most the durable version justifies charging
- `repairBeatsReplace` - repair cost per remaining year vs a new one's
- `annualizedTCO` - price plus repairs, spread over real lifespan

All money math runs on `Decimal`, so gear audits never inherit
floating-point drift. Pure Foundation, no dependencies, iOS 13+ / macOS
10.15+, Swift 5.9.

## Why

Sticker price punishes durable goods. A cheap item replaced three times
costs more per decade than the heirloom version bought once, but only
when the math is laid out year by year. This pod prices both paths
directly: annual cost, decade cost, the break-even year for the premium
option, and the point where a repair stops being worth it.

## Usage

    let math = DurableCostMath()
    let decades = try math.costPerDecade(price: 180, lifespanYears: 10)
    // decades = 180: $18 a year, $180 a decade

    let repair = try math.repairBeatsReplace(
        repairCost: 90, remainingYears: 6,
        replacementPrice: 120, replacementLifespanYears: 4)
    // repair = true: $15/yr to fix beats $30/yr to replace

## Installation (CocoaPods)

    pod 'DurableCostMath', '~> 0.1'

Built by the [Durable Picks](https://www.durablepicks.com) team, which
publishes cost-per-decade breakdowns and repairability scoring for
buy-it-for-life gear.

## License

MIT
