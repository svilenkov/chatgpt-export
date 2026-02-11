# chatgpt-export

CLI tools to search, filter, and extract ChatGPT conversation exports received via email after clicking on "Settings > Data Controls > Export Data"

## Setup
```bash
cp .env.example .env
# Edit .env with your export path
```

## Usage
```bash
./count.sh              # List all conversations
./search.sh "keyword"   # Search by title
./filter.sh "Title"     # Extract convo to convo.json
./extract.sh            # Dump messages to convo_lines.txt
./cp-files.sh           # Copy attachments
```

### Filtering
```bash
./search.sh 'Skb' | (read -r h; echo "$h"; sort -k4 -nr)
```
Output:
```
ID                                    FROM        TO          MSGS  TITLE
8f119964-ec19-421f-b29f-4a582ddc032d  2024-07-02  2024-07-03  141   Skb_shared_info Fragments Explanation
2383c317-b550-40bb-b2b7-ba73ed07dcfb  2024-07-01  2024-07-01  41    Allocate SKBs using PFMEMALLOC
```

```bash
./filter.sh --id 2383c317-b550-40bb-b2b7-ba73ed07dcfb
```
Now you can run `./extract.sh` to turn convo.json into readable `convo_lines.txt`

### Extracting
This will give you convo_lines.txt. Useful to just paste into other LLMs such as Claude
```bash
./extract.sh
extracted 'Allocate SKBs using PFMEMALLOC' to convo_lines.txt (499 lines, 5986 words)
```

### Searching
Eg. sort results by message count

```bash
./search.sh 'RAG' | (read -r h; echo "$h"; sort -k4 -nr)
```
Example output:
```ini
ID                                    FROM        TO          MSGS  TITLE
68fe24b3-7e4c-8326-a9cf-9a2a93204ab5  2025-10-26  2025-10-26  286   RAG diagram explanation
8f119964-ec19-421f-b29f-4a582ddc032d  2024-07-02  2024-07-03  141   Skb_shared_info Fragments Explanation
67581ebc-50f0-8009-8dd7-e3a04f45efca  2024-12-10  2024-12-10  74    RS Average Gain Explained
6979d7a8-aed4-832a-849d-7f26a2b6af8e  2026-01-28  2026-01-28  43    Tokoya in Hiragana
67fa8c28-94e4-8009-8e31-c75d354d23ca  2025-04-12  2025-04-12  32    Local RAG Pipeline Setup
68f698d9-cec8-8326-9581-d02cf1356858  2025-10-20  2025-10-21  22    CRAG vs state-machine RAG
67f08d75-b968-8009-9cef-6b544561146d  2025-04-05  2025-04-05  14    RAG Context Augmentation Limits
c9f3b5cd-c71a-4e03-992d-c1d26e2ca9bd  2024-04-10  2024-04-10  10    Heap-based State Storage Model
4f414a18-71f6-423f-86ea-f6ee32761d23  2024-01-28  2025-12-25  8     WiscKey: Separating Keys from Values in SSD-conscious Storage
2a6108ca-a992-4747-98de-ce4c79de3de8  2024-01-27  2024-01-27  2     Decentralized Storage Network Restructure
```