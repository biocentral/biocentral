# biocentral_server.spec
import os
import sys
from pathlib import Path
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

from ncbi_refseq_accession_db import db as db_db
from ncbi_refseq_accession_lengths import db as lengths_db
from ncbi_refseq_accession_offsets import db as offsets_db
from ncbi_taxon_db import db_dir as taxon_db_dir

block_cipher = None

# Collect all data files for taxoniq
datas = collect_data_files('taxoniq')
datas.append((db_db, 'taxoniq'))
datas.append((lengths_db, 'taxoniq'))
datas.append((offsets_db, 'taxoniq'))
taxa_files = [os.path.join(taxon_db_dir, f) for f in os.listdir(taxon_db_dir) if
              os.path.isfile(os.path.join(taxon_db_dir, f))]
for taxa_file in taxa_files:
    datas.append((taxa_file, 'taxoniq'))

# Add icon
icon_path = str(Path("assets/icons/biocentral_icon.ico").absolute())

# Add assets
assets_path = str(Path("assets").absolute())
datas.append((assets_path, "assets"))

# Add hidden imports of taxoniq
hiddenimports = collect_submodules('taxoniq')

# Add Python interpreter
python_interpreter = (sys.executable, '.')

a = Analysis(['run-biocentral_server.py'],
             pathex=[],
             binaries=[python_interpreter],
             datas=datas,
             hiddenimports=hiddenimports,
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='biocentral_server',
          icon=icon_path,
          debug=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=True)
