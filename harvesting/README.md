# OJS Tools - Harvesting

These scripts are used to harvest OJS journal content via OAI. The main script is `run_harvest.sh`, which uses both the `get_full_text.sh` script and `pyoaiharvest.py` (from https://github.com/vphill/pyoaiharvester). These scripts use the JATS metadata format by default, but could be adapted for other formats.