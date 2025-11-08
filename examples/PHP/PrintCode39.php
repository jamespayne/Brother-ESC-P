<?php
/**
 * Simple Brother ESC/P barcode sender
 * Usage:
 *   php PrintCode39.php 192.168.X.X "BOX-2048"
 *   where 192.168.X.X is the IP address of your printer and "BOX-2048" is
 *   the data you want to send.
 */

// --- Read command line args ---
$ip   = $argv[1];
$data = $argv[2];

// --- Helper: send raw ESC/P data to printer ---
function sendToPrinter(string $ip, string $rawData, int $port = 9100): void
{
    $errno = 0;
    $errstr = '';
    echo "Connecting to $ip:$port...\n";

    $fp = @fsockopen($ip, $port, $errno, $errstr, 5);
    if (!$fp) {
        fwrite(STDERR, "ERROR: Could not connect to $ip:$port ($errstr, $errno)\n");
        exit(1);
    }

    fwrite($fp, $rawData);
    fflush($fp);
    fclose($fp);

    echo "Sent " . strlen($rawData) . " bytes to printer.\n";
}

// --- Build ESC/P CODE39 barcode job ---
function buildEscpBarcodeJob(string $barcodeData): string
{
    // ESC/P setup
    $bytes = [
        0x1B, 0x69, 0x61, 0x00,  // ESC i a 00h -> ESC/P mode
        0x1B, 0x40,              // ESC @       -> initialize
    ];

    // Minimal ESC i B barcode (no parameters -> default CODE39)
    $bytes = array_merge($bytes, [0x1B, 0x69, 0x42]); // ESC i  B

    foreach (str_split($barcodeData) as $ch) {
        $bytes[] = ord($ch);
    }

    $bytes[] = 0x5C;             // "\" terminator
    $bytes[] = 0x0C;             // FF -> print (and cut if auto-cut is ON)

    return pack('C*', ...$bytes);
}

// --- Build the job and send it ---
$raw = buildEscpBarcodeJob($data);
sendToPrinter($ip, $raw);

echo "Printed CODE39 barcode for \"$data\" on $ip\n";