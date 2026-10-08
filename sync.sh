#!/bin/bash
# Synchronisation automatique du dossier élève vers GitHub (commits « gitautosync update N »).
# À lancer dans un terminal le matin de la formation : ./sync.sh
cd "$(dirname "$0")"
exec gitautopush . --sleep 30
