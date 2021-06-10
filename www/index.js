async function connect() {
  const navigate = () => {
    window.location.href = 'https://app.amigosapp.nl';
  };

  // if (navigator.onLine) {
  //   navigate();
  // }

  return new Promise((resolve, reject) => {
    fetch('https://google.com/', { mode: 'no-cors' })
      .then(navigate)
      .catch(() => {
        document.getElementById('status').innerHTML = 'There is no connection to the server';
        resolve(false);
      });
  });
}

connect();

async function retry() {
  document.getElementById('status').innerHTML = 'Connecting...';
  if (!(await connect())) {
    alert("Can't connect to server");
  }
}
