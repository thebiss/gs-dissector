

# References
- Documentation indicates all data is stored within ANSI C.12.19 tables
- https://en.wikipedia.org/wiki/ANSI_C12.19
    - ANSI C12.21 for communication of tables over model
    - ANSI C12.22 for communication of tables over network
    - IEC 61968 

# Useful Commands
### find patterns in hexdump, then pass through color
`grep --color=always "50 CF 55 D9 E6 80" Oncor_Capture_01-07-2023_30hrs.txt.hd | sort | less -R`

# We want / expect to see measurements like:
- Voltage - around 240
- Voltage phase angle - degrees

- Current - up to 100/200/400
- Current phase angle - degrees

- Active power (W)
- Apparent power (VA)
- Reactive power (VAr)

- Power Factor

- Energy / time (e.g this hour, today): kWh


# Open Items

## Report Uptime and Unknown (0x30)
### there are round decimal numbers lurking in the payload...
- unknown value of a4 83 = 33700 decimal, oddly round
- unparsed payload 1c 25 = 9500
- unparsed payload 3c af = 44860
- 0x1293 = 4755
- 0x124e = 4686 ?


## Forwards (0xd5) of subtype  0xC0 - Observations:
- Are very similar, for chunks of time, across device IDs
- Broadcast to ID 0xFFFFFFFF and max FF:FF:FF:FF:FF:FF

Payload starts with 0xfefef27f

- Octets 6&7 change for each device/xmit
- Last 6 OCTETS change change for each device/xmit
- Middle payload stays the same for some time.

Is this come kind of beacon that is forwarded?
Is one of the fields a hop-count, decrementing?


```
                                                         vv vv increments every new change to the data. 29,2a,2b,2c,2d,2e,etc...
fe fe fe 7f 00 3d 03 02 3d f8 97 c1 80 00 00 00 02 03 00 02 2a 3f 31 58 07 16 01 40 b0 f6 60 bb 3d a7 f6 a9 cd 55 26 0f ec cb e2 c0 50 10 1e 55 da 65 80 ba 50 bd 9a 08 5e 3a 47 94 f0 60 af 9e 2f f4 2e a9 23 be 50 27 80 65 c3 57 91 92 59 04 c3 b3 04 fe d0 b2 b0 93 a2 80 05 f0 08 27 d3 50 cf 20 15 d9 1b 3c 81 19 5e 15 d7 81 a6 02 78 8e cc 0c 7a 78 2e 59 18 e0 07 d4 d3 00 3e 8c 05 b8 2c 3d 98 00 07 10 09 70 06 52 31 72 c0 0e 11 16 0a eb 49 8f dd 69 31 d1 38 a0 ba 52 22 e0 01 85 16 ba d2 63 42 4f 84 08 68 20 1f d9 6e 91 09 58 50 07 d0 f2 80 3e ab fd 0a da 08 8a 05 53 fb 6e e7 c2 40 3c 82 22 28 78 5f da 86 e2 12 b5 f8 00 5b 01 0c 0c 0a 14 ba c4 21 d8 0a 28 84 27 09 7e 20 b1 d5

```


## Forwards (0xd5) with payloads of len 22 have the following patterns
### of subtype 0x21 
octet 1: 88, 98, or b8
octet 5: value is either 0x32 or 0x6c, nothing else, matching 50 or 108 decimal
octet 4: values are continuous between 0x20 and 0x30
octet 6: values are either 4-5-6

### of subtype 0x22: 
    octet 1: is only 0x01 or 0x0f

### of subtype 0x29
    octet 1 is 90 or 98

```
Frame 645540: 28 bytes on wire (224 bits), 28 bytes captured (224 bits)
    Encapsulation type: USER 0 (45)
    Arrival Time: Apr 16, 2024 22:19:22.645539000 Eastern Daylight Time
    UTC Arrival Time: Apr 17, 2024 02:19:22.645539000 UTC
    Epoch Arrival Time: 1713320362.645539000
    [Time shift for this packet: 0.000000000 seconds]
    [Time delta from previous captured frame: 0.000001000 seconds]
    [Time delta from previous displayed frame: 0.000004000 seconds]
    [Time since reference or first frame: 0.645539000 seconds]
    Frame Number: 645540
    Frame Length: 28 bytes (224 bits)
    Capture Length: 28 bytes (224 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: gridstream]
    [Coloring Rule Name: New coloring rule]
    [Coloring Rule String: gridstream.type == 0xd5]
GRIDSTREAM Protocol
    start: 0x00ff
    flags: Unknown (0x2a)
    type: forward (0xd5)
    Message
        flags?: 00
        len: 22
        subtype: Unknown (0x29)
            dest meter ID: f0:f2:8e:f7
            src meter  ID: f0:54:2f:4a
            packet count: 0xe8
            payload len: 6
            payload raw: 98 01 00 29 32 05
            timing? (0.01s): 11798
            unknown: 1a 50
            checksum: 0xdbcd

```


## Field unk1 (first field in the message) is likely a BITFIELD / 1-hot flags
- This field is frequently zero
- It only is SINGLE BIT VALUES values
```
    0x00
    0x01
    0x02
    0x04
    0x04
    0x10
    0x20
    0x40
    0x80
``` 

## Device IDs found repeating across more packet types
### ID  `f0 b4 4c a3`

command: `egrep --color=always -i '00 FF 2A D5 .* f0 b4 4c a3' Oncor_Capture_01-07-2023_30hrs.txt.hd `

```
											vvvvvvvvv
000000   00 FF 2A 55 00 23 30 FF FF FF FF FF FF 50 CF 55 D9 E6 C0 92 00 D3 D2 75 A4 83 F0 B4 4C A3 01 00 26 32 05 2A 17 7E 90 02 D4
					  vvvvvvvvvvv                                             
000000   00 FF 2A D5 00 FD C0 FF FF FF FF F0 B4 4C A3 94 FD 8B 1F 8D FF FF FF FF 00 08 FF FF FF FF FF FF FE FE FE 7F 00 3A 01 02 22 0F E3 C1 80 00 00 00 02 03 00 03 42 DE 34 82 8A 06 44 BF 5C 17 FA E9 CB FD E7 FD 70 BF D8 12 D6 50 82 2B 00 09 69 A3 BF E0 1E E1 03 7A 54 F6 E0 82 5C B6 FF F9 97 F3 E3 74 9B 7F 73 2A 74 01 ED 90 04 C2 04 13 FD A5 01 58 48 58 0A C0 34 85 14 11 A4 28 D4 A5 01 46 88 20 37 3F 86 CC 08 D8 38 20 49 41 6A 82 B0 68 08 0E 72 44 6E BC 78 04 12 E7 14 BA F1 A0 02 CF 41 00 81 FF A7 80 11 89 26 00 8C 10 03 A1 84 00 1D 13 30 20 40 21 9F E8 F8 02 D0 08 78 00 02 D0 41 00 16 8A 1E 00 81 50 83 9D 40 01 08 D8 40 08 40 82 1A 00 14 82 41 E6 7B 70 68 C0 F9 85 70 15 02 EB C1 84 C0 00 4B 44 02 00 21 80 5C 03 13 BA F0 61 61 F4 40 06 40 32 58 FD A8 5B 78 2B 6B 7E 40 4A 79
000000   00 FF 2A D5 00 FD C0 FF FF FF FF F0 B4 4C A3 96 FD 8B 1F 8D FF FF FF FF 00 08 FF FF FF FF FF FF FE FE FE 7F 00 39 01 02 22 0F E3 C1 80 00 00 00 02 03 00 03 42 DE 34 82 8A 06 44 BF 5C 17 FA E9 CB FD E7 FD 70 BF D8 12 D6 50 82 2B 00 09 69 A3 BF E0 1E E1 03 7A 54 F6 E0 82 5C B6 FF F9 97 F3 E3 74 9B 7F 73 2A 74 01 ED 90 04 C2 04 13 FD A5 01 58 48 58 0A C0 34 85 14 11 A4 28 D4 A5 01 46 88 20 37 3F 86 CC 08 D8 38 20 49 41 6A 82 B0 68 08 0E 72 44 6E BC 78 04 12 E7 14 BA F1 A0 02 CF 41 00 81 FF A7 80 11 89 26 00 8C 10 03 A1 84 00 1D 13 30 20 40 21 9F E8 F8 02 D0 08 78 00 02 D0 41 00 16 8A 1E 00 81 50 83 9D 40 01 08 D8 40 08 40 82 1A 00 14 82 41 E6 7B 70 68 C0 F9 85 70 15 02 EB C1 84 C0 00 4B 44 02 00 21 80 5C 03 13 BA F0 61 61 F4 40 06 40 32 58 FD A8 5B 78 2C 0B 7E 60 FE 36
000000   00 FF 2A D5 00 FD C0 FF FF FF FF F0 B4 4C A3 98 FD 8B 1F 8D FF FF FF FF 00 08 FF FF FF FF FF FF FE FE FE 7F 00 37 01 02 22 0F E3 C1 80 00 00 00 02 03 00 03 42 DE 34 82 8A 06 44 BF 5C 17 FA E9 CB FD E7 FD 70 BF D8 12 D6 50 82 2B 00 09 69 A3 BF E0 1E E1 03 7A 54 F6 E0 82 5C B6 FF F9 97 F3 E3 74 9B 7F 73 2A 74 01 ED 90 04 C2 04 13 FD A5 01 58 48 58 0A C0 34 85 14 11 A4 28 D4 A5 01 46 88 20 37 3F 86 CC 08 D8 38 20 49 41 6A 82 B0 68 08 0E 72 44 6E BC 78 04 12 E7 14 BA F1 A0 02 CF 41 00 81 FF A7 80 11 89 26 00 8C 10 03 A1 84 00 1D 13 30 20 40 21 9F E8 F8 02 D0 08 78 00 02 D0 41 00 16 8A 1E 00 81 50 83 9D 40 01 08 D8 40 08 40 82 1A 00 14 82 41 E6 7B 70 68 C0 F9 85 70 15 02 EB C1 84 C0 00 4B 44 02 00 21 80 5C 03 13 BA F0 61 61 F4 40 06 40 32 58 FD A8 5B 78 2C E9 7E 40 3F 69
000000   00 FF 2A D5 00 FD C0 FF FF FF FF F0 B4 4C A3 9A FD 8B 1F 8D FF FF FF FF 00 08 FF FF FF FF FF FF FE FE FE 7F 00 35 01 02 22 0F E3 C1 80 00 00 00 02 03 00 03 42 DE 34 82 8A 06 44 BF 5C 17 FA E9 CB FD E7 FD 70 BF D8 12 D6 50 82 2B 00 09 69 A3 BF E0 1E E1 03 7A 54 F6 E0 82 5C B6 FF F9 97 F3 E3 74 9B 7F 73 2A 74 01 ED 90 04 C2 04 13 FD A5 01 58 48 58 0A C0 34 85 14 11 A4 28 D4 A5 01 46 88 20 37 3F 86 CC 08 D8 38 20 49 41 6A 82 B0 68 08 0E 72 44 6E BC 78 04 12 E7 14 BA F1 A0 02 CF 41 00 81 FF A7 80 11 89 26 00 8C 10 03 A1 84 00 1D 13 30 20 40 21 9F E8 F8 02 D0 08 78 00 02 D0 41 00 16 8A 1E 00 81 50 83 9D 40 01 08 D8 40 08 40 82 1A 00 14 82 41 E6 7B 70 68 C0 F9 85 70 15 02 EB C1 84 C0 00 4B 44 02 00 21 80 5C 03 13 BA F0 61 61 F4 40 06 40 32 58 FD A8 5B 78 2D B1 7E 40 0D 6B
											vvvvvvvvv
000000   00 FF 2A 55 00 23 30 FF FF FF FF FF FF 50 CF 55 D9 E6 C0 A8 00 D3 D2 98 A4 83 F0 B4 4C A3 01 00 26 32 05 37 7D 7E 90 EC 4B
000000   00 FF 2A 55 00 23 30 FF FF FF FF FF FF 50 CF 55 D9 E6 C0 BC 00 D3 D2 C0 A4 83 F0 B4 4C A3 01 00 26 32 05 05 73 7E 90 35 F3
000000   00 FF 2A 55 00 23 30 FF FF FF FF FF FF 50 CF 55 D9 E6 C0 C4 00 D3 D2 C8 A4 83 F0 B4 4C A3 01 00 26 32 05 08 BB 7E 90 2F 87
```




## Investigate - Repeating patterns of `00 2d 32 06` across 3 packet types
```csv                                                                                                                                                                                          vvvvvvvvvvv  
"18542","Report up-time and unknown","broadcast","Report uptime and other unknown data","35","","18968566","","","11","0x68","","ff:ff:ff:ff:ff:ff","50:cf:7d:d9:e3:20","f0:91:46:1c","01 00 2d 32 06 39 22 7e 00 5a b6","a4 83",""
                                                                                                                               vvvvvvvvvvv
"18543","Report up-time and unknown","forward","Unk 0x21","22","","","f0:53:eb:19","f1:27:20:ae","6","0xca","","","","","b8 01 00 2d 32 06","1c 50",""
                    
"18544","Report up-time and unknown","forward","Epoch and Uptime","71","Jan  7, 2023 22:26:03.000000000 UTC","18968568","f0:53:eb:19","f1:27:20:ae","29","0xcc","00 01 fb 3a","","50:cf:bd:d9:e3:80","f0:53:eb:19","00 01 03 24 03 04 05 06 03 08 05 07 00 00 00 01 e4 60 00 2d 32 06 02 c9 20 30 20 81 80","1c 20",""
^^^^^^^^^^^
```

Filters found...
- (6) `gridstream.info.payload contains 01:00:2d:32:06` shows 18542 instances!
- (5) `gridstream.info.payload contains 01:00:2d:32:05` also frequent, seem to intermix...
- (3) `gridstream.info.payload contains 01:00:2d:32:03` also frequent, seem to intermix...

### some meters use ONLY 05, others start 03, then switch to 06.
```
"205165","Report up-time and unknown","broadcast","Report uptime and other unknown data","35","","18991344","","","11","0xc4","","ff:ff:ff:ff:ff:ff","50:cf:95:d9:e5:e0","f0:2e:65:89","01 00 2d 32 06 08 bb 7e 90 06 6e","a4 83",""
```


## Type 0x55 Broadcast
regex: `00 FF 2A 55 .* F0 F9 61 56`

```hd
                  vv
                                                                                       meter ID seen in other packets
                                                                                       vvvvvvvvvvv
000000	 00 FF 2A 55 00 23 30 FF FF FF FF FF FF 50 CF 55 D9 E6 80 96 00 0B 62 6A A4 83 F0 F9 61 56 01 00 2B 32 05 15 DB 7E 90 A9 88	
                        ^^ ^^ ^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^ ^^ ^^^^^
                        len   broadcast mac?    frequent          |  |09,0a,0b
                                                EB 19 F6 98       count by 2
                                                also seen in D5 packages
```

## 0x00FF 0x2AD5 broadcast  packet, with a tail that starts similarly to other (00 01 03 24 pattern)
```
                        vv length?
000000   00 FF 2A D5 00 47 51 F0 55 F7 86 F0 B4 4C A3 E2 63 BA 01 0C 00 01 D5 10 00 D3 EA 37 A4 83 01 01 50 CF 55 D9 E6 C0 F0 B4 4C 
                                                                                                                                    A3 00 01 03 24 05 0A 04 07 05 01 06 03 00 00 00 05 62 E8 00 27 32 05 02 75 20 30 20 81 80 37 35 22 00 33 2B 
                                                                                                                                       ^^^^^^^^^^^
```


## Patterns in payloads
- Type 0x21 \
    Only 0x88's can end with extra 04
    
- src meter ID \
    f0:b4:4c:a3 - is most interesting
    
Packets for the meter come with payloads length
```
    len @[0]  @[1] etc...
    1
        B8
        91
        90
        98
    6
        98
        88
        91
        90
        B8 then
            01 00    
    7
        88 
            then 01
        90 
            then 06
        91 
            then 06
        
        -> B8 not found    
    12 
        90  
        91 then
            01 00
    
    
    13 (few!)
        90
        91 then
            08 00 ALWAYS
    
    29
        look totally different
        start with 
        00 01 03 24..
``` 

    
Type 0x29 seems to have varying some changing slowly
    slow changing expectations:  
        Temperature should be slow and similar across meters
        Frequency
        
    time of day changes
        usage, esp changes on the hour.
        
    

# Closed Items

## (closed) Length Field is likely wrong

- None of the packets captured are bigger than 259 bytes (frame.len)
- Using a 2-byte fields yields larger results which can't be valid.
- placed  prior byte into an Unk1 


## (closed) Counting up field 
Example from meter (gridstream.info.src_meter_id2 == f0:f9:61:56)

```
packet 470      7 Jan 2023 21:45:69 - 00 01 eb 72 =  125,810
packet 1549     7 Jan 2023 21:49:26 - 00 01 f3 88 =  127,880
```

Calculated
```
Time        diff                unk field	    decimal     difference
Stamps      hh:mm:ss  ss.frac                               (approx sec x10)
21:46:09			            0x0001 eb72	    125810	
21:49:26	0:03:17	 197.00 	0x0001 f388	    127880	    2070
21:50:09	0:00:43	  43.00	    0x0001 f536	    128310	    430
```

values also fit into other uptime fields.


## (closed - yes there was) Is there an alignment issue?
```
GRIDSTREAM Protocol packet
    start: 0x00ff
    type: Report up-time and unknown (0x2a)
    subtype: forward (0xd5)
Informational
    len: 28
    type: Meter Data? (0x29)
        meter 1 ID: f0:61:1c:3e
                          AAAAA
        meter 2 ID: f0:3b:9f:fb
                    BBBBBBBBBBB
        count: 0x69
                 CC
        payload len: 19
        payload raw: 1c 3e f0 3b 9f fb 69 90 01 00 1f 6c 04 06 00 9f 50 b9 10
                     AAAAA BBBBBBBBBBB CC then 12 octets.. 
        timing (0.01s): 10583
        unk 3: 16 70
        checksum: 0x207f
```
```
		Meter 2 ID	fixed		le?	le?		le?		count?		
d9 e5 e0 	f1 5d 58 a5 	00 01 03 24 	05 07 	09 06 08 01 	05 01 00 00 	00 01 f0 18 	@@00 2c 32 06 02 be 	20 30 20 81 80
```


## time notes
63:bb:db:69
