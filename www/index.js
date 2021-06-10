function navigate() {
  window.location.href = 'https://app.amigosapp.nl';
}

async function canConnect() {
  if (navigator.onLine) {
    return true;
  }

  return new Promise((resolve) => {
    fetch('https://app.amigosapp.nl/', { mode: 'no-cors' })
      .then(() => {
        resolve(true);
      })
      .catch(() => {
        resolve(false);
      });
  });
}
async function connect(init = false) {
  document.getElementById('status').innerHTML = 'Connecting...';

  const _canConnect = await canConnect();

  if (_canConnect) {
    navigate();
  } else {
    if (!init) {
      alert("Can't connect to server");
    }

    document.getElementById('status').innerHTML = 'There is no connection to the server';
  }
}

connect(true);

document.getElementById('retry-button').addEventListener('click', () => connect());
