<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Crypto Panel</title>
    <style>
        body { font-family: sans-serif; background: #eef2f7; display: flex; justify-content: center; padding: 20px; }
        .box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); width: 100%; max-width: 500px; border-top: 5px solid #0056b3; }
        .tabs { display: flex; gap: 5px; margin-bottom: 20px; }
        .tabs button { flex: 1; padding: 10px; cursor: pointer; border: none; background: #ddd; border-radius: 4px; font-weight: bold; }
        .tabs button.active { background: #007bff; color: white; }
        .panel { display: none; }
        .panel.active { display: block; }
        label { font-size: 11px; font-weight: bold; display: block; margin-top: 10px; }
        input, textarea { width: 100%; padding: 8px; margin-top: 4px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-family: monospace; }
        button.exec { width: 100%; margin-top: 15px; padding: 12px; cursor: pointer; border: none; border-radius: 4px; background: #218838; color: white; font-weight: bold; }
        .res { margin-top: 15px; padding: 10px; background: #f8f9fa; border-radius: 4px; font-size: 12px; word-break: break-all; border: 1px solid #ddd; }
    </style>
</head>
<body>

<div class="box">
    <div class="tabs">
        <button onclick="tab(0)" id="t0" class="active">Szyfr</button>
        <button onclick="tab(1)" id="t1">Deszyfr</button>
        <button onclick="tab(2)" id="t2">SHA256</button>
    </div>

    <!-- Szyfrowanie -->
    <div id="p0" class="panel active">
        <label>Tekst do zaszyfrowania:</label>
        <textarea id="e_data" rows="3"></textarea>
        <button class="exec" onclick="enc()">Szyfruj AES</button>
        <div id="e_res" class="res">Gotowy.</div>
    </div>

    <!-- Deszyfrowanie -->
    <div id="p1" class="panel">
        <label>Pakiet (IV+Tag+Text):</label>
        <textarea id="d_pack" rows="3"></textarea>
        <label>Klucz:</label>
        <input type="text" id="d_key">
        <button class="exec" style="background:#007bff" onclick="dec()">Deszyfruj AES</button>
        <div id="d_res" class="res">Czekam na dane.</div>
    </div>

    <!-- SHA256 -->
    <div id="p2" class="panel">
        <label>Tekst do hashowania:</label>
        <textarea id="s_data" rows="3"></textarea>
        <button class="exec" style="background:#6c757d" onclick="sh()">Generuj SHA256</button>
        <div id="s_res" class="res">Wpisz tekst.</div>
    </div>
</div>

<script>
    const toB64 = (b) => btoa(String.fromCharCode(...new Uint8Array(b)));
    const fromB64 = (s) => Uint8Array.from(atob(s), c => c.charCodeAt(0));

    function tab(idx) {
        document.querySelectorAll('.panel, .tabs button').forEach(el => el.classList.remove('active'));
        document.getElementById('p' + idx).classList.add('active');
        document.getElementById('t' + idx).classList.add('active');
    }

    async function enc() {
        const txt = document.getElementById('e_data').value;
        if(!txt) return;
        const rk = crypto.getRandomValues(new Uint8Array(32));
        const k = await crypto.subtle.importKey("raw", rk, "AES-GCM", false, ["encrypt"]);
        const iv = crypto.getRandomValues(new Uint8Array(12));
        const encd = await crypto.subtle.encrypt({name: "AES-GCM", iv}, k, new TextEncoder().encode(txt));
        const pack = new Uint8Array(iv.length + encd.byteLength);
        pack.set(iv, 0); pack.set(new Uint8Array(encd), 12);
        document.getElementById('e_res').innerHTML = `KLUCZ:<br><input readonly value="${toB64(rk)}"><br>PAKIET:<br><textarea readonly>${toB64(pack)}</textarea>`;
    }

    async function dec() {
        try {
            const p64 = document.getElementById('d_pack').value;
            const k64 = document.getElementById('d_key').value;
            const fd = fromB64(p64);
            const k = await crypto.subtle.importKey("raw", fromB64(k64), "AES-GCM", false, ["decrypt"]);
            const res = await crypto.subtle.decrypt({name: "AES-GCM", iv: fd.slice(0,12)}, k, fd.slice(12));
            document.getElementById('d_res').innerText = "Wynik: " + new TextDecoder().decode(res);
        } catch(e) { document.getElementById('d_res').innerText = "Blad danych"; }
    }

    async function sh() {
        const d = new TextEncoder().encode(document.getElementById('s_data').value);
        const h = await crypto.subtle.digest('SHA-256', d);
        document.getElementById('s_res').innerText = "Hash: " + Array.from(new Uint8Array(h)).map(b => b.toString(16).padStart(2,'0')).join('');
    }
</script>

</body>
</html>
