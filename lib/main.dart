<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="mobile-web-app-capable" content="yes">
    <title>DZAFA DLMS</title>
    
    <style>
        /* TEMA GELAP PROFESIONAL */
        :root {
            --bg-main: #1e1e1e;
            --bg-panel: #2d2d30;
            --text-main: #ffffff;
            --border-color: #3f3f46;
            --btn-bg: #3e3e42;
            --btn-hover: #505050;
            --color-in-a: #ff3b30; /* Merah */
            --color-in-b: #0a84ff; /* Biru */
            --color-out: #30d158;  /* Hijau */
        }

        body {
            margin: 0; padding: 0; background-color: var(--bg-main); color: var(--text-main);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow: auto; user-select: none;
        }

        #portrait-warning {
            display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
            background-color: #000; z-index: 9999; color: #0ff;
            text-align: center; justify-content: center; align-items: center; flex-direction: column;
        }
        @media screen and (orientation: portrait) {
            #portrait-warning { display: flex; }
            #app-container { display: none !important; }
        }

        /* --- LAYOUT UTAMA --- */
        #app-container {
            display: flex; min-width: 950px; min-height: 440px;
            padding: 10px; box-sizing: border-box; gap: 15px; height: 100vh;
        }

        /* --- PANEL KIRI (Master) --- */
        .left-panel {
            width: 120px; background-color: var(--bg-panel); border: 1px solid var(--border-color);
            border-radius: 5px; display: flex; flex-direction: column; align-items: center; padding: 10px;
            position: relative; z-index: 50; flex-shrink: 0;
        }
        .status-box {
            width: 100%; padding: 8px 0; text-align: center; background-color: #550000; color: #ff5555;
            font-weight: bold; font-size: 12px; border-radius: 3px; margin-bottom: 20px; border: 1px solid #ff5555; cursor: pointer;
        }
        .status-box.connected { background-color: #004400 !important; color: #55ff55 !important; border-color: #55ff55 !important; }
        
        .master-mute-btn {
            width: 100%; padding: 10px 0; background-color: var(--btn-bg); color: white; border: 1px solid var(--border-color);
            border-radius: 3px; cursor: pointer; font-size: 12px; font-weight: bold; margin-bottom: 10px;
        }
        .master-mute-btn.active { background-color: #ff3b30 !important; border-color: #ff3b30 !important; }

        .master-fader-area {
            flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: space-between;
            border: 1px solid var(--border-color); border-radius: 3px; width: 100%; padding: 10px 0; background-color: #252526;
        }
        .master-fader-area span { font-size: 11px; color: #aaa; font-weight: bold; }
        .master-fader-area strong { font-size: 14px; margin-top: auto;}
        
        input[type=range] {
            -webkit-appearance: slider-vertical; writing-mode: bt-lr; cursor: pointer;
        }
        .master-fader-area input[type=range] { flex: 1; width: 25px; margin: 10px 0; }

        /* --- PANEL KANAN --- */
        .right-panel { flex-grow: 1; display: flex; flex-direction: column; gap: 10px; }

        /* AREA ROUTING */
        .routing-area {
            flex: 1; background-color: var(--bg-panel); border: 1px solid var(--border-color);
            border-radius: 5px; display: flex; position: relative; padding: 10px; min-height: 200px;
        }
        
        .routing-col { display: flex; flex-direction: column; justify-content: flex-start; z-index: 50; position: relative; }
        .inputs-col { width: 350px; gap: 8px;}
        .outputs-col { width: 400px; gap: 8px;}
        
        /* HEADER & NODE LINKED */
        .header-linked {
            font-size: 11px; color: #aaa; text-align: center; border-bottom: 1px solid #444; 
            padding-bottom: 3px; font-weight: bold; letter-spacing: 1px; margin-bottom: 4px;
        }
        .link-container { display: flex; justify-content: center; gap: 15px; margin-bottom: 10px; }
        .link-item {
            display: flex; align-items: center; gap: 8px; background-color: #333; cursor: pointer;
            padding: 4px 10px; border-radius: 3px; border: 1px solid #444; font-weight: bold; font-size: 12px;
        }
        .link-item.active { background-color: #444; color: #0ff; border-color: #0ff; }
        .link-box { width: 10px; height: 10px; border: 1px solid #777; background-color: #111; border-radius: 2px; }
        .link-item.active .link-box { background-color: #0ff; border-color: #0ff; box-shadow: 0 0 5px #0ff; }

        /* BARIS CHANNEL */
        .channel-row { display: flex; align-items: center; gap: 5px; height: 35px; }
        
        .btn-module {
            background-color: var(--btn-bg); color: white; border: 1px solid var(--border-color); border-radius: 2px;
            padding: 5px; font-size: 11px; cursor: pointer; height: 28px; flex: 1; text-align: center;
        }
        .btn-module:hover { background-color: var(--btn-hover); }
        .btn-mute {
            background-color: var(--btn-bg); color: white; border: 1px solid var(--border-color); border-radius: 2px;
            padding: 5px; font-size: 11px; cursor: pointer; width: 40px; height: 28px;
        }
        .btn-mute.active { background-color: #ff3b30 !important; border-color: #ff3b30 !important; }

        .lbl-chan {
            background-color: #111; border: 1px solid #555; font-size: 12px; font-weight: bold;
            text-align: center; height: 26px; line-height: 26px; width: 60px;
        }
        .lbl-in-a { color: var(--color-in-a); border-color: var(--color-in-a); }
        .lbl-in-b { color: var(--color-in-b); border-color: var(--color-in-b); }
        .lbl-out { color: var(--color-out); border-color: var(--color-out); }

        /* NODE ROUTING (DIBESARKAN 20x20 AGAR MUDAH DIKLIK DI HP) */
        .port-dot {
            width: 20px; height: 20px; border-radius: 50%; margin: 0 5px; cursor: pointer;
            position: relative; z-index: 60; transition: 0.2s; border: 2px solid #555; background-color: #222;
        }
        .port-dot.selected { transform: scale(1.3); border: 2px solid #fff; box-shadow: 0 0 8px #fff; }
        .port-dot.in-a { background-color: var(--color-in-a); border-color: var(--color-in-a); }
        .port-dot.in-b { background-color: var(--color-in-b); border-color: var(--color-in-b); }

        /* CANVAS MATRIKS */
        .matrix-canvas { flex-grow: 1; position: relative; min-width: 80px; z-index: 1; }
        #svg-lines { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }

        /* --- FADERS AREA DENGAN VU --- */
        .faders-area {
            height: 190px; flex-shrink: 0;
            background-color: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 5px;
            display: flex; padding: 10px; gap: 8px; justify-content: space-around; position: relative; z-index: 50;
        }
        
        .fader-group {
            display: flex; flex-direction: column; align-items: center; border: 1px solid var(--border-color); 
            background-color: #252526; width: 65px; padding: 5px 2px; border-radius: 3px;
        }
        .fader-header { font-size: 10px; margin-bottom: 5px; text-align: center; width: 100%; border-bottom: 1px solid #444; padding-bottom: 3px; font-weight: bold;}
        
        .fader-body { display: flex; align-items: center; justify-content: center; gap: 4px; height: 110px; width: 100%; margin-bottom: 5px; }
        
        .fader-scale {
            display: flex; flex-direction: column; justify-content: space-between; height: 100px;
            font-size: 8.5px; color: #888; text-align: right; width: 15px; font-family: monospace;
        }
        
        .fader-body input[type=range] { width: 15px; height: 100px; margin: 0;}

        /* VU Meter */
        .vu-container {
            width: 8px; height: 100px; background-color: #111; border: 1px solid #444;
            border-radius: 2px; position: relative; overflow: hidden; display: flex; align-items: flex-end;
        }
        .vu-bar {
            width: 100%; height: 0%;
            background: linear-gradient(to top, #30d158 55%, #ffd60a 80%, #ff3b30 100%);
            transition: height 0.1s ease-out;
        }

        .val-display { font-size: 11px; margin-top: auto; background: #000; padding: 2px 5px; border-radius: 2px; color: #0ff; font-weight: bold;}
    </style>
</head>
<body>

    <div id="portrait-warning">
        <h2>🔄 Putar HP Anda</h2>
        <p>Gunakan mode Landscape (Mendatar) untuk kontrol penuh.</p>
    </div>

    <div id="app-container">
        <!-- PANEL KIRI -->
        <div class="left-panel">
            <div id="status-koneksi" class="status-box" onclick="toggleKoneksi()">DISCONNECTED</div>
            <button id="btn-master-mute" class="master-mute-btn" onclick="toggleMute(this)">ALL MUTE</button>
            <div class="master-fader-area">
                <span>MASTER</span>
                <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-master')">
                <strong id="val-master">0.0 dB</strong>
            </div>
        </div>

        <!-- PANEL KANAN -->
        <div class="right-panel">
            <!-- AREA ROUTING -->
            <div class="routing-area">
                <!-- BLOK INPUT -->
                <div class="routing-col inputs-col">
                    <div class="header-linked">___ Input Linked ___</div>
                    <div class="link-container">
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>A</span></div>
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>B</span></div>
                    </div>
                    
                    <div class="channel-row">
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                        <div class="lbl-chan lbl-in-a">In A</div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">G/DEQ</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="port-dot in-a" id="node-in-0" onclick="selectInput(0)"></div>
                    </div>
                    <div class="channel-row">
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                        <div class="lbl-chan lbl-in-b">In B</div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">G/DEQ</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="port-dot in-b" id="node-in-1" onclick="selectInput(1)"></div>
                    </div>
                </div>

                <!-- KANVAS MATRIKS -->
                <div class="matrix-canvas" id="matrix-container">
                    <svg id="svg-lines"></svg>
                </div>

                <!-- BLOK OUTPUT -->
                <div class="routing-col outputs-col">
                    <div class="header-linked">___ Output Linked ___</div>
                    <div class="link-container">
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>1</span></div>
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>2</span></div>
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>3</span></div>
                        <div class="link-item" onclick="toggleLink(this)"><div class="link-box"></div><span>4</span></div>
                    </div>

                    <div class="channel-row">
                        <div class="port-dot" id="node-out-0" onclick="connectToOutput(0)"></div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">PEQ</button>
                        <button class="btn-module">X-Over</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="lbl-chan lbl-out">Out 1</div>
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                    </div>
                    <div class="channel-row">
                        <div class="port-dot" id="node-out-1" onclick="connectToOutput(1)"></div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">PEQ</button>
                        <button class="btn-module">X-Over</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="lbl-chan lbl-out">Out 2</div>
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                    </div>
                    <div class="channel-row">
                        <div class="port-dot" id="node-out-2" onclick="connectToOutput(2)"></div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">PEQ</button>
                        <button class="btn-module">X-Over</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="lbl-chan lbl-out">Out 3</div>
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                    </div>
                    <div class="channel-row">
                        <div class="port-dot" id="node-out-3" onclick="connectToOutput(3)"></div>
                        <button class="btn-module">Gain</button>
                        <button class="btn-module">PEQ</button>
                        <button class="btn-module">X-Over</button>
                        <button class="btn-module">Delay</button>
                        <button class="btn-module">Phase</button>
                        <div class="lbl-chan lbl-out">Out 4</div>
                        <button class="btn-mute" onclick="toggleMute(this)">Mute</button>
                    </div>
                </div>
            </div>

            <!-- FADERS AREA DENGAN VU -->
            <div class="faders-area">
                <!-- Input A -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-in-a)">INPUT A</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-in-a')">
                        <div class="vu-container"><div class="vu-bar" id="vu-in-a"></div></div>
                    </div>
                    <div class="val-display" id="val-in-a">0.0</div>
                </div>
                <!-- Input B -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-in-b)">INPUT B</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-in-b')">
                        <div class="vu-container"><div class="vu-bar" id="vu-in-b"></div></div>
                    </div>
                    <div class="val-display" id="val-in-b">0.0</div>
                </div>
                <!-- Output 1 -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-out)">OUTPUT 1</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-out-1')">
                        <div class="vu-container"><div class="vu-bar" id="vu-out-1"></div></div>
                    </div>
                    <div class="val-display" id="val-out-1">0.0</div>
                </div>
                <!-- Output 2 -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-out)">OUTPUT 2</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-out-2')">
                        <div class="vu-container"><div class="vu-bar" id="vu-out-2"></div></div>
                    </div>
                    <div class="val-display" id="val-out-2">0.0</div>
                </div>
                <!-- Output 3 -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-out)">OUTPUT 3</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-out-3')">
                        <div class="vu-container"><div class="vu-bar" id="vu-out-3"></div></div>
                    </div>
                    <div class="val-display" id="val-out-3">0.0</div>
                </div>
                <!-- Output 4 -->
                <div class="fader-group">
                    <div class="fader-header" style="color:var(--color-out)">OUTPUT 4</div>
                    <div class="fader-body">
                        <div class="fader-scale"><span>12</span><span>0</span><span>-12</span><span>-24</span><span>-40</span><span>-60</span></div>
                        <input type="range" min="-60" max="12" step="0.5" value="0" oninput="updateVal(this, 'val-out-4')">
                        <div class="vu-container"><div class="vu-bar" id="vu-out-4"></div></div>
                    </div>
                    <div class="val-display" id="val-out-4">0.0</div>
                </div>
            </div>
        </div>
    </div>

    <!-- SEMUA JAVASCRIPT DILETAKKAN DI BAWAH AGAR AMAN DARI BLOKIR BROWSER HP -->
    <script>
        // Logika Status Koneksi
        function toggleKoneksi() {
            let box = document.getElementById('status-koneksi');
            if (box.innerText === "DISCONNECTED") {
                box.innerText = "CONNECTED";
                box.classList.add('connected');
            } else {
                box.innerText = "DISCONNECTED";
                box.classList.remove('connected');
            }
        }

        // Logika Tombol Mute & Link
        function toggleMute(btn) { btn.classList.toggle('active'); }
        function toggleLink(element) { element.classList.toggle('active'); }
        
        // Logika Slider
        function updateVal(slider, textId) {
            let val = parseFloat(slider.value).toFixed(1);
            document.getElementById(textId).innerText = val + (textId === 'val-master' ? ' dB' : '');
        }

        // --- SISTEM ROUTING KLIK-KE-KLIK ---
        let activeInputSelected = -1; 
        
        let connections = [
            [true, false], [true, false], [false, true], [false, true]  
        ];

        function selectInput(inIndex) {
            document.getElementById('node-in-0').classList.remove('selected');
            document.getElementById('node-in-1').classList.remove('selected');
            
            if (activeInputSelected === inIndex) {
                activeInputSelected = -1; // Matikan jika diklik lagi
            } else {
                activeInputSelected = inIndex; // Hidupkan
                document.getElementById('node-in-' + inIndex).classList.add('selected');
            }
        }

        function connectToOutput(outIndex) {
            if (activeInputSelected !== -1) {
                connections[outIndex][activeInputSelected] = !connections[outIndex][activeInputSelected];
                drawRoutingLines();
            } else {
                alert("KLIK PERTAMA PADA INPUT DULU:\nKlik titik Input A atau B terlebih dahulu sampai menyala, baru klik titik Output untuk menyambung/memutus garis.");
            }
        }

        // Kalkulasi titik tengah yang presisi untuk garis
        function getCenterPoint(element) {
            const rect = element.getBoundingClientRect();
            return {
                x: rect.left + rect.width / 2,
                y: rect.top + rect.height / 2
            };
        }

        function drawRoutingLines() {
            const svg = document.getElementById('svg-lines');
            const container = document.getElementById('matrix-container');
            svg.innerHTML = ''; 

            const containerRect = container.getBoundingClientRect();
            const colors = ['var(--color-in-a)', 'var(--color-in-b)'];

            for (let outIdx = 0; outIdx < 4; outIdx++) {
                let outNode = document.getElementById('node-out-' + outIdx);
                let endCenter = getCenterPoint(outNode);
                
                let end = { 
                    x: endCenter.x - containerRect.left, 
                    y: endCenter.y - containerRect.top 
                };

                let hasInA = connections[outIdx][0];
                let hasInB = connections[outIdx][1];

                // Update warna titik output
                if (hasInA && hasInB) {
                    outNode.style.backgroundColor = '#aa00ff'; outNode.style.borderColor = '#aa00ff';
                } else if (hasInA) {
                    outNode.style.backgroundColor = colors[0]; outNode.style.borderColor = colors[0];
                } else if (hasInB) {
                    outNode.style.backgroundColor = colors[1]; outNode.style.borderColor = colors[1];
                } else {
                    outNode.style.backgroundColor = '#222'; outNode.style.borderColor = '#555';
                }

                // Gambar garis
                for(let inIdx = 0; inIdx < 2; inIdx++) {
                    if (connections[outIdx][inIdx]) {
                        let inNode = document.getElementById('node-in-' + inIdx);
                        let startCenter = getCenterPoint(inNode);
                        let start = { 
                            x: startCenter.x - containerRect.left, 
                            y: startCenter.y - containerRect.top 
                        };

                        let line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                        line.setAttribute('x1', start.x);
                        line.setAttribute('y1', start.y);
                        line.setAttribute('x2', end.x);
                        line.setAttribute('y2', end.y);
                        line.setAttribute('stroke', colors[inIdx]);
                        line.setAttribute('stroke-width', '2');
                        svg.appendChild(line);
                    }
                }
            }
        }

        // Jalankan penggambar garis saat semua elemen sudah siap
        window.onload = function() {
            setTimeout(drawRoutingLines, 150);
        };
        window.addEventListener('resize', drawRoutingLines);

        // Simulasi pergerakan VU Meter
        setInterval(() => {
            const vus = document.querySelectorAll('.vu-bar');
            vus.forEach(vu => {
                let level = Math.random() * 70 + 10;
                vu.style.height = level + '%';
            });
        }, 150);
    </script>
</body>
</html>