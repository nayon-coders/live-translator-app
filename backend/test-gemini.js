const geminiKey = process.env.GEMINI_KEY;
fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateBidiToken?key=${geminiKey}`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({})
}).then(r => r.json()).then(console.log).catch(console.error);
