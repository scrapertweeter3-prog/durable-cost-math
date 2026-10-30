import Foundation

/// Durable-goods cost math: the numbers that decide whether a buy-it-for-life
/// price is a bargain or a luxury. A tag is not a cost; price over lifespan
/// is. This library prices gear the way long-term owners actually experience
/// it: annual cost, cost per decade, cost per use, the lifespan a premium
/// purchase needs to break even, when a repair beats a replacement, and the
/// most a longer-lasting version can justify charging.
///
/// All money math runs on `Decimal`, so gear audits never inherit
/// floating-point drift. Pure Foundation, no dependencies.
public enum DurableCostMathError: Error, Equatable {
    case nonPositiveLifespan
    case negativeMoney
    case nonPositiveUses
    case nonPositiveRemaining
}

public struct DurableCostMath {

    public init() {}

    // MARK: - Annual and decade cost

    /// True annual cost of ownership: price spread over the years the item
    /// actually lasts. The number a $180 pair of socks over a decade
    /// ($18/yr) wins against a $30 pair over one year ($30/yr).
    @discardableResult
    public func annualCost(price: Decimal, lifespanYears: Decimal) throws -> Decimal {
        guard lifespanYears > 0 else { throw DurableCostMathError.nonPositiveLifespan }
        if price < 0 { throw DurableCostMathError.negativeMoney }
        return price / lifespanYears
    }

    /// The comparison shoppers actually feel: what ten years of the item
    /// costs, whatever the sticker said. Annual cost scaled to a decade.
    @discardableResult
    public func costPerDecade(price: Decimal, lifespanYears: Decimal) throws -> Decimal {
        return try annualCost(price: price, lifespanYears: lifespanYears) * 10
    }

    /// Cost per single use: price divided by every time the item gets used
    /// over its life. The daily-carry lens on a purchase decision.
    @discardableResult
    public func costPerUse(price: Decimal, lifespanYears: Decimal, usesPerYear: Decimal) throws -> Decimal {
        guard usesPerYear > 0 else { throw DurableCostMathError.nonPositiveUses }
        return try annualCost(price: price, lifespanYears: lifespanYears) / usesPerYear
    }

    // MARK: - Break-even for the premium option

    /// The lifespan the premium purchase must reach for its annual cost to
    /// drop to the cheap option's. A premium item that dies before this year
    /// was the expensive choice all along.
    @discardableResult
    public func premiumBreakEvenYears(cheapPrice: Decimal, cheapLifespanYears: Decimal, premiumPrice: Decimal) throws -> Decimal {
        guard cheapLifespanYears > 0 else { throw DurableCostMathError.nonPositiveLifespan }
        if premiumPrice < 0 { throw DurableCostMathError.negativeMoney }
        let cheapAnnual = try annualCost(price: cheapPrice, lifespanYears: cheapLifespanYears)
        guard cheapAnnual > 0 else { throw DurableCostMathError.negativeMoney }
        return premiumPrice / cheapAnnual
    }

    /// The most the longer-lasting version can charge before its per-year
    /// cost loses to the cheap one: the price at which both options cost
    /// the same per year of life.
    @discardableResult
    public func priceAtParity(cheapPrice: Decimal, cheapLifespanYears: Decimal, premiumLifespanYears: Decimal) throws -> Decimal {
        guard cheapLifespanYears > 0 && premiumLifespanYears > 0 else { throw DurableCostMathError.nonPositiveLifespan }
        if cheapPrice < 0 { throw DurableCostMathError.negativeMoney }
        return cheapPrice * (premiumLifespanYears / cheapLifespanYears)
    }

    // MARK: - Repair or replace

    /// True when repairing beats buying new: repair cost per remaining year
    /// of service against the replacement's annual cost. The repairability
    /// question priced instead of argued.
    @discardableResult
    public func repairBeatsReplace(repairCost: Decimal, remainingYears: Decimal, replacementPrice: Decimal, replacementLifespanYears: Decimal) throws -> Bool {
        guard remainingYears > 0 else { throw DurableCostMathError.nonPositiveRemaining }
        let repairAnnual = try annualCost(price: repairCost, lifespanYears: remainingYears)
        let replaceAnnual = try annualCost(price: replacementPrice, lifespanYears: replacementLifespanYears)
        return repairAnnual <= replaceAnnual
    }

    /// Annualized total cost of ownership once repairs enter the picture:
    /// purchase price plus every repair, spread over the years the item
    /// lasts. The number warranty fine print is written to obscure.
    @discardableResult
    public func annualizedTCO(price: Decimal, repairCosts: [Decimal], lifespanYears: Decimal) throws -> Decimal {
        guard lifespanYears > 0 else { throw DurableCostMathError.nonPositiveLifespan }
        var total = price
        for c in repairCosts {
            if c < 0 { throw DurableCostMathError.negativeMoney }
            total += c
        }
        return total / lifespanYears
    }
}
