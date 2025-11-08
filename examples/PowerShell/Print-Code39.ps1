function Print-Code39 {
    param(
        [string]$PrinterIP,
        [int]   $Port = 9100,
        [string]$BarcodeData
    )

    <#
        .SYNOPSIS
        Prints a CODE39 barcode with the human readable data as text below
        the barcode.

        .PARAMETER PrinterIP
        Specifies the IP address of your printer

        .PARAMETER Port
        Specifies the port that we should connect to the printer with. 9100 will
        be used as default if not set.

        .EXAMPLE
        Using abitrary data:
        PS> Print-Code39 -PrinterIP "XXX.XXX.XXX.XXX" -BarcodeData "12345"

        .EXAMPLE
        PS> $boxId = "BX-2048"
        PS> Print-Code39 -PrinterIP "XXX.XXX.XXX.XXX" -BarcodeData $boxId

        .LINK
        https://github.com/jamespayne/Brother-ESC-P
    #>

    # Collect all bytes as integers
    $bytesList = @()

    # --- ESC/P setup ---
    $bytesList += 0x1B,0x69,0x61,0x00   # ESC i a 00h -> ESC/P mode
    $bytesList += 0x1B,0x40             # ESC @       -> initialize

    # --- Minimal ESC i B barcode (no parameters, defaults to CODE39) ---
    # Format: ESC i [Parameters] B [data] \
    # Here:   ESC i        B "your data" \
    $bytesList += 0x1B,0x69,0x42        # ESC i  B
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes($BarcodeData)
    $bytesList += 0x5C                  # "\" terminator

    # --- End of page: print (and cut, assuming auto-cut is ON) ---
    $bytesList += 0x0C                  # FF

    # Convert to strict byte[]
    $bytes = [byte[]]$bytesList

    # Send to printer
    $client = [System.Net.Sockets.TcpClient]::new($PrinterIP, $Port)
    $stream = $client.GetStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush()
    $stream.Close()
    $client.Close()
}