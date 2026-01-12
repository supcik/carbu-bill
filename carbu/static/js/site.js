async function waitForUrl(url, interval = 2000) {
  while (true) {
    try {
      const response = await fetch(url, { mode: 'no-cors' })
      if (response.ok || response.status === 0) return true // Found!
    } catch (e) {
      // Ignore errors
    }
    await new Promise((resolve) => setTimeout(resolve, interval))
  }
}
