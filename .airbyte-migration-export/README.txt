This folder captures the current Docker Compose Airbyte setup before migrating to abctl.

Files:
- airbyte-migration-bundle.json: recreated source, destination, connection, and CDC state details.

Notes:
- Old Airbyte URL: http://127.0.0.1:8000
- Old Airbyte version: 0.63.15
- Docker Compose to modern Airbyte migration is not officially supported, so this bundle is the rebuild reference.
- The Snowflake password was recovered from the current Airbyte config database so the destination can be recreated without manual re-entry.
