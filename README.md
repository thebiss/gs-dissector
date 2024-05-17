# Purpose
Make the data posted in https://wiki.recessim.com/view/Landis%2BGyr_GridStream_Protocol#Data_captures
more readible, by enabling WireShark support for the protocol through a
custom dissector written in LUA.

### Please contribute!
- **This dissector is alpha quality, with fields definitions based upon descriptions in page above and my own additional reverse engineering.** 
- **_PLEASE submit a pull request or create an issue if you discover new fields!_**

![Example of a capture](docs/Screenshot%202024-05-03%20172003.png)

# Pre-requisites
- **WireShark** - provides the user interface for packet navigation and analysis
- **tshark ("term shark")** - provides command-line tools to create PCAP files, naive plugin testing.
- **a linux-like environment** - provides and shell and GNU tools for capture processing

# Use
## Step 1:  Create a capture (PCAP) from source text files (run once, already run)
- See `sample-cap/*-txt-to-hd-to-pcap.sh` for examples of how text files from the link above were first converted to hex dumps, using awk, sed, etc., then converted into PCAP files.
- The scripts flag the PCAP files with a custom protocol ID

## Step 2: Copy the `gridstream.lua` plugin to the Wireshark plugin directory
- See the file `promote.sh` for an example specific to WireShark portable on Windows 11.

## Step 3: Start Wireshark
- Load wireshark.
- Open a pcap file from the `sample-cap` folder.
- Wireshark should automatically detect the custom protocol in the PCAP file, select the matching custom dissector plugin, and display the dissected packets.

## Step 4: Iterate!
- Identify new patterns in the messages, and modify the dissector to decompose those fields.
- Submit an issue or PR with your changes!

