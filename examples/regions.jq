[
  .Regions[].RegionName |
  select(IN($regions[])) |
  {
    "key": ("guardduty_" + .),
    "value": {
      "source": $source,
      "aws_region": .,
      "parameters": "${local.parameters}"
    }
  }
] |
from_entries |
{
  "module": .
}
