#!/usr/bin/env python3
"""FinOps governance: flag running EC2 instances missing the required cost tags.

You can't allocate spend you never tagged, and retro-tagging is archaeology — so
catch it early. Run on a schedule (or in CI) and alert on the non-zero exit.

    pip install boto3
    python3 find_untagged.py          # needs ec2:DescribeInstances
"""
import sys
import boto3

REQUIRED = {"owner", "project", "env"}   # the tags every resource must carry


def untagged(region="us-east-1"):
    ec2 = boto3.client("ec2", region_name=region)
    offenders = []
    pages = ec2.get_paginator("describe_instances").paginate(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )
    for page in pages:
        for res in page["Reservations"]:
            for inst in res["Instances"]:
                tags = {t["Key"].lower() for t in inst.get("Tags", [])}
                missing = REQUIRED - tags
                if missing:
                    offenders.append((inst["InstanceId"], sorted(missing)))
    return offenders


if __name__ == "__main__":
    bad = untagged()
    for iid, missing in bad:
        print(f"{iid}: missing {', '.join(missing)}")
    sys.exit(1 if bad else 0)   # non-zero so cron / CI actually alerts
