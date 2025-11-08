# Brother ESC/P

This is a collection of scripts that I have created to experiement with printing
labels to Brother label printers using ESC/P. Hopefully I can provide a range of
exmaples that people can use to print to Brother printers in different
languages.

# Motivation

I currently work in an environment where we use barcodes and a Brother label
printer to assist with things like asset tracking, shipping and logistics.

# Testing

Testing has been carried out on the following Brother label printers:

* Brother QL-820NWB

# Printer Settings

With my Brother QL-820NWB, I had to make sure that "Command Mode" was set to
"ESC/P" under Menu > Administration > Command Mode.

# Scripts and relevant notes

## Print-EscpBarcode.ps1

CODE39 allows A–Z, 0–9, space, and - . $ / + %. Keep your data inside that set
for maximum compatibility.