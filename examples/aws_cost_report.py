#!/usr/bin/env python3
"""Month-to-date AWS cost, broken down by service, via the Cost Explorer API.

    pip install boto3
    python3 aws_cost_report.py        # needs ce:GetCostAndUsage

Note: Cost Explorer charges ~$0.01 per API call, and the current month lags ~24h —
so run it on a schedule (daily), not in a tight loop.
"""
import boto3
import datetime as dt


def month_to_date_by_service():
    today = dt.date.today()
    start = today.replace(day=1).isoformat()
    end = (today + dt.timedelta(days=1)).isoformat()  # CE end date is exclusive
    ce = boto3.client("ce")
    resp = ce.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )
    rows = []
    for period in resp["ResultsByTime"]:
        for g in period["Groups"]:
            amount = float(g["Metrics"]["UnblendedCost"]["Amount"])
            if amount > 0:
                rows.append((g["Keys"][0], amount))
    return sorted(rows, key=lambda r: -r[1])


if __name__ == "__main__":
    total = 0.0
    for service, amount in month_to_date_by_service():
        print(f"{amount:9.2f}  {service}")
        total += amount
    print(f"{total:9.2f}  TOTAL (month-to-date, USD)")
