function Print-EscpRepairLabel {
    param(
        [string]$PrinterIP,
        [int]   $Port = 9100,
        [string]$AssetTag,
        [string]$SerialNumber,
        [string]$IssueDescription
    )

    $bytesList = @()

    # --- ESC/P mode + init ---
    $bytesList += 0x1B,0x69,0x61,0x00    # ESC i a 00h -> ESC/P mode
    $bytesList += 0x1B,0x40              # ESC @       -> initialize

    # =====================================================
    # 1) HEADER – "REPAIR" (Helsinki outline, 50 dots)
    # =====================================================

    # Select outline font: n=11 (0x0B) -> Helsinki outline
    $bytesList += 0x1B,0x6B,0x0B
    # Set character size: ESC X m nL nH
    $bytesList += 0x1B,0x58,0x00,0x32,0x00
    # Add header text
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes("REPAIR")
    $bytesList += 0x0D,0x0A,0x0D,0x0A    # CR LF x2

    # =====================================================
    # 2) DETAILS – Asset, Serial, Issue
    # =====================================================

    # Use a smaller outline font for body text (33 dots)
    $bytesList += 0x1B,0x6B,0x0B
    $bytesList += 0x1B,0x58,0x00,0x21,0x00

    # Asset Tag
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes("Asset Tag: $AssetTag")
    $bytesList += 0x0D,0x0A

    # Serial Number
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes("Serial No:  $SerialNumber")
    $bytesList += 0x0D,0x0A

    # Issue Description
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes("Issue:      $IssueDescription")
    $bytesList += 0x0D,0x0A,0x0D,0x0A

    # =====================================================
    # 3) BARCODE – Serial number as CODE39
    # =====================================================

    # ESC i B <data> \
    $bytesList += 0x1B,0x69,0x42
    $bytesList += [System.Text.Encoding]::ASCII.GetBytes($SerialNumber)
    $bytesList += 0x5C  # "\" terminator

    # =====================================================
    # 4) PRINT & CUT
    # =====================================================

    $bytesList += 0x1B,0x69,0x43,0x01    # Full cut
    $bytesList += 0x0C                   # FF (print)

    # Convert to byte[] and send
    $bytes = [byte[]]$bytesList

    $client = [System.Net.Sockets.TcpClient]::new($PrinterIP, $Port)
    $stream = $client.GetStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush()
    $stream.Close()
    $client.Close()
}

# Example call
# Print-EscpRepairLabel -PrinterIP "192.168.1.18" `
#     -AssetTag "A12345" `
#     -SerialNumber "SN001234" `
#     -IssueDescription "Screen flickering. Tried rebooting. No use. Tried restarting, no good. The system has been re-imaged with no change."
