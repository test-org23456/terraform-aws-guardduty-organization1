[
  .Regions[].RegionName |
  select(IN($regions[])) |
  {
    "key": ($prefix + .),
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
