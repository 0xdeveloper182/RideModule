# Database Migrations Guide

This directory contains all database migration scripts for the Nammayatri backend.

## Quick Start

### Option 1: Using Direct Commands (Recommended)

```bash
cd ~/nammayatri-main/Backend/dev/migrations

# Set connection string
CONN_STRING="host=localhost port=5432 user=atlas_dev dbname=atlas_dev password=root"

# Run Rider App migrations
for f in $(ls -1 rider-app/*.sql | sort); do
  echo "Running: $f"
  psql "$CONN_STRING" -f "$f"
done

# Run Driver App migrations
for f in $(ls -1 dynamic-offer-driver-app/*.sql | sort); do
  echo "Running: $f"
  psql "$CONN_STRING" -f "$f"
done
```

### Option 2: Using the Helper Script

```bash
cd ~/nammayatri-main/Backend/dev

# Make it executable
chmod +x run_all_migrations.sh

# Run all migrations
./run_all_migrations.sh

# Run only rider app
./run_all_migrations.sh --rider-only

# Run only driver app
./run_all_migrations.sh --driver-only

# Verify database connection only
./run_all_migrations.sh --verify-only
```

### Option 3: Using the Original Script with Environment Variables

```bash
cd ~/nammayatri-main/Backend/dev/migrations

# Set environment variables
export PGHOST=localhost
export PGPORT=5432
export PGUSER=atlas_dev
export PGPASSWORD=root

# Run migrations
./run_migrations.sh ./rider-app
./run_migrations.sh ./dynamic-offer-driver-app
```

## Directory Structure

```
migrations/
├── run_migrations.sh                    # Original migration script
├── rider-app/                           # Rider app migrations (~700 files)
│   ├── 0000-db-init.sql                # Database initialization
│   ├── 0001-local-testing-data.sql     # Test data
│   └── ... (0003 to 0717)
├── dynamic-offer-driver-app/            # Driver app migrations (~1500 files)
│   ├── 0000-db-init.sql
│   ├── 0001-local-testing-data.sql
│   └── ... (1013 to 1469)
└── migrations-after-release/            # Post-release migrations
    ├── rider-app/
    └── dynamic-offer-driver-app/
```

## Connection Details

Default configuration:
- **Host:** localhost
- **Port:** 5432
- **User:** atlas_dev
- **Password:** root
- **Database:** atlas_dev

## Common Commands

### Run all migrations
```bash
CONN_STRING="host=localhost port=5432 user=atlas_dev dbname=atlas_dev password=root"
for f in $(ls -1 rider-app/*.sql dynamic-offer-driver-app/*.sql | sort); do
  psql "$CONN_STRING" -f "$f"
done
```

### Run single migration
```bash
psql -h localhost -U atlas_dev -d atlas_dev -f rider-app/0000-db-init.sql
```

### Check migration progress
```bash
psql -h localhost -U atlas_dev -d atlas_dev -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';"
```

### Backup database
```bash
pg_dump -h localhost -U atlas_dev -d atlas_dev > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore database
```bash
psql -h localhost -U atlas_dev -d atlas_dev < backup_2025_12_07.sql
```

## Troubleshooting

### Connection Refused
```bash
# Check PostgreSQL service
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql
```

### Authentication Failed
```bash
# Test with psql directly
psql -h localhost -U atlas_dev -d atlas_dev -c "SELECT 1"

# Check PostgreSQL configuration
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

### Database Does Not Exist
```bash
# Create database
sudo -u postgres createdb atlas_dev
sudo -u postgres psql -c "ALTER DATABASE atlas_dev OWNER TO atlas_dev;"
```

## Migration Files

Migration files follow a naming convention:
```
NNNN-<description>.sql

Examples:
- 0000-db-init.sql
- 0003-fare.sql
- 1013-add-id-and-driverId-to-RCR-table.sql
```

**Important:** Migrations must be run in numerical order due to foreign key dependencies.

## Documentation

- [Full Migration Guide](DATABASE_MIGRATIONS_UBUNTU.md)
- [Quick Reference Commands](QUICK_MIGRATION_COMMANDS.md)
- [Backend README](../README.md)

## Need Help?

See [QUICK_MIGRATION_COMMANDS.md](QUICK_MIGRATION_COMMANDS.md) for:
- One-liner scripts
- Environment-based commands
- Common troubleshooting fixes
- Tips & best practices
