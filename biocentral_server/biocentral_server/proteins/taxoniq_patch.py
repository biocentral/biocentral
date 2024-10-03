import os
import sys
import logging

from ..utils import get_bundle_dir

logger = logging.getLogger(__name__)


def patch_taxoniq_if_bundled():
    """
    Taxoniq relies on databases that were not automatically bundled via pyinstaller. After bundling,
    this patch needs to be applied in the pyinstaller environment in order for taxoniq to find the correct
    database paths.
    """
    import taxoniq
    from taxoniq import Taxon, DatabaseService
    if getattr(sys, 'frozen', False):
        # running in a PyInstaller bundle
        bundle_dir = get_bundle_dir()

        # Update the _db_dir
        Taxon._db_dir = os.path.join(bundle_dir, 'taxoniq')

        # Update all the file paths in _db_files
        for key, (db_type, filename) in Taxon._db_files.items():
            new_filename = os.path.join(bundle_dir, 'taxoniq', os.path.basename(filename))
            Taxon._db_files[key] = (db_type, new_filename)

        # Patch the _get_db method to use the updated paths
        original_get_db = DatabaseService._get_db

        def patched_get_db(self, db_name):
            if db_name not in self._databases:
                db_type, filename = self._db_files[db_name]
                if not os.path.exists(filename):
                    # If the file doesn't exist, try finding it in the bundle directory
                    bundle_filename = os.path.join(bundle_dir, 'taxoniq', os.path.basename(filename))
                    if os.path.exists(bundle_filename):
                        self._db_files[db_name] = (db_type, bundle_filename)
                        filename = bundle_filename
                return original_get_db(self, db_name)
            return self._databases[db_name]

        DatabaseService._get_db = patched_get_db

        logger.debug(f"Patched taxoniq db dir - Taxon._db_dir: {Taxon._db_dir}")
