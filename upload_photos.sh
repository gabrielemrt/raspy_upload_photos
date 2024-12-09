#!/usr/bin/env bash

# Configurazioni da personalizzare
SOURCE_DEVICE="/media/usb"           # Path di mount della microSD del drone
DRONE_MEDIA_PATH="DCIM/100MEDIA"     # Sottocartella nella microSD con foto/video
TARGET_BASE_PATH="/home/pi/SynologyDrive"  # Path della cartella sincronizzata con Synology Drive

# Data odierna in formato YYYY-MM-DD
TODAY=$(date +%Y-%m-%d)
# Calcoliamo la data di domani per limitare l'intervallo di ricerca dei file.
TOMORROW=$(date -d "$TODAY +1 day" +%Y-%m-%d)

# Cambia directory nella cartella sorgente
cd "$SOURCE_DEVICE/$DRONE_MEDIA_PATH" || { echo "Cartella sorgente non trovata!"; exit 1; }

# Trova i file modificati a partire dalla mezzanotte del giorno corrente fino alla mezzanotte di domani.
FILES=$(find . -maxdepth 1 -type f -newermt "$TODAY" ! -newermt "$TOMORROW")

# Se non ci sono file, esci
if [ -z "$FILES" ]; then
    echo "Nessun file trovato per la data odierna."
    exit 0
fi

# Copia i file, organizzandoli nella cartella di destinazione
for f in $FILES; do
    CLEANF=$(basename "$f")
    # Estrae la parte prima del primo underscore come prefisso.
    PREFIX=$(echo "$CLEANF" | sed 's/\([^_]*\).*/\1/')

    # Crea la cartella di destinazione con il formato anno-mese-giorno_(prefisso)
    DEST_DIR="$TARGET_BASE_PATH/${TODAY}_(${PREFIX})"
    mkdir -p "$DEST_DIR"

    # Copia il file nella cartella destinazione
    cp -v "$f" "$DEST_DIR/"
done

echo "Copia completata con successo!"
