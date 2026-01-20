# NIFTY Turnover vs Next-Day Market Behavior

This project analyzes NIFTY daily market data using SQL.

## Problem Statement
If today’s turnover is higher than the previous week’s average,
what usually happens the next trading day?

## Logic Used
Turnover is analyzed together with price movement to understand
strong buying or strong selling behavior.

## Approach
- Calculated weekly average turnover
- Compared current turnover with previous week using window functions
- Used LAG and LEAD for time-based comparison
- Analyzed next-day gap up, gap down, and higher-high continuation
- Converted outcomes into probabilities

## Tools
- SQL (CTEs, Window Functions)

This project connects trading experience with data analysis.
