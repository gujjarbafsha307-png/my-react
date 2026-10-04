import { useState } from 'react'
import './App.css'

const OWNER_USERNAME = 'Ayan'
const OWNER_PASSWORD = '000467'

function App() {
	const [showWelcome, setShowWelcome] = useState(true)
	const [page, setPage] = useState('welcome')
	const [username, setUsername] = useState('')
	const [password, setPassword] = useState('')
	const [loginError, setLoginError] = useState('')
	const [customerName, setCustomerName] = useState('')
	const [customerPhone, setCustomerPhone] = useState('')
	const [customerMessage, setCustomerMessage] = useState('')

	const handleWelcomeOk = () => {
		console.log('OK button clicked')
		setShowWelcome(false)
		setPage('role-selection')
	}

	const handleOwnerLogin = (event) => {
		event.preventDefault()
		if (username === OWNER_USERNAME && password === OWNER_PASSWORD) {
			setLoginError('')
			setPage('owner-dashboard')
			return
		}
		setLoginError('Username or password is incorrect.')
	}

	const handleCustomerSubmit = (event) => {
		event.preventDefault()
		setCustomerMessage(`Welcome, ${customerName}! Your details have been received.`)
	}

	const goBack = () => {
		setLoginError('')
		setCustomerMessage('')
		setPage('role-selection')
	}

	return (
		<main className="flow-shell">
			{showWelcome && (
				<div className="flow-backdrop" role="presentation">
					<section className="flow-panel welcome-panel" role="dialog" aria-modal="true" aria-labelledby="welcome-title">
						<span className="flow-mark" aria-hidden="true">✦</span>
						<p className="flow-kicker">Malik Adrees Shop &amp; UA Trader</p>
						<h1 id="welcome-title">Assalamualaikum</h1>
						<p className="flow-copy">Welcome to Malik Adrees Shop &amp; UA Trader</p>
						<button className="flow-button flow-button-primary" type="button" onClick={handleWelcomeOk}>
							OK <span aria-hidden="true">→</span>
						</button>
					</section>
				</div>
			)}

			{!showWelcome && page === 'role-selection' && (
				<section className="flow-panel" aria-labelledby="role-title">
					<p className="flow-kicker">Malik Adrees Shop &amp; UA Trader</p>
					<h1 id="role-title">Welcome</h1>
					<p className="flow-copy">Choose how you would like to continue.</p>
					<div className="flow-actions">
						<button className="flow-button flow-button-primary" type="button" onClick={() => setPage('owner-login')}>
							Owner <span aria-hidden="true">→</span>
						</button>
						<button className="flow-button flow-button-secondary" type="button" onClick={() => setPage('customer-login')}>
							Customer <span aria-hidden="true">→</span>
						</button>
					</div>
				</section>
			)}

			{!showWelcome && page === 'owner-login' && (
				<section className="flow-panel" aria-labelledby="owner-login-title">
					<button className="flow-back" type="button" onClick={goBack}>← Back</button>
					<p className="flow-kicker">Owner access</p>
					<h1 id="owner-login-title">Owner Login</h1>
					<p className="flow-copy">Sign in to manage the shop.</p>
					<form className="flow-form" onSubmit={handleOwnerLogin}>
						<label htmlFor="owner-username">Username</label>
						<input id="owner-username" name="username" autoComplete="username" value={username} onChange={(event) => setUsername(event.target.value)} required />
						<label htmlFor="owner-password">Password</label>
						<input id="owner-password" name="password" type="password" autoComplete="current-password" value={password} onChange={(event) => setPassword(event.target.value)} required />
						{loginError && <p className="flow-error" role="alert">{loginError}</p>}
						<button className="flow-button flow-button-primary" type="submit">Log in <span aria-hidden="true">→</span></button>
					</form>
				</section>
			)}

			{!showWelcome && page === 'owner-dashboard' && (
				<section className="flow-panel" aria-labelledby="dashboard-title">
					<p className="flow-kicker">Owner account</p>
					<h1 id="dashboard-title">Owner Dashboard</h1>
					<p className="flow-copy">You are signed in as {OWNER_USERNAME}.</p>
					<button className="flow-button flow-button-secondary" type="button" onClick={goBack}>Sign out</button>
				</section>
			)}

			{!showWelcome && page === 'customer-login' && (
				<section className="flow-panel" aria-labelledby="customer-title">
					<button className="flow-back" type="button" onClick={goBack}>← Back</button>
					<p className="flow-kicker">Customer account</p>
					<h1 id="customer-title">Register or Sign In</h1>
					<p className="flow-copy">Enter your details to continue.</p>
					<form className="flow-form" onSubmit={handleCustomerSubmit}>
						<label htmlFor="customer-name">Name</label>
						<input id="customer-name" name="name" autoComplete="name" value={customerName} onChange={(event) => setCustomerName(event.target.value)} required />
						<label htmlFor="customer-phone">Phone number</label>
						<input id="customer-phone" name="phone" type="tel" autoComplete="tel" value={customerPhone} onChange={(event) => setCustomerPhone(event.target.value)} required />
						{customerMessage && <p className="flow-success" role="status">{customerMessage}</p>}
						<button className="flow-button flow-button-primary" type="submit">Continue <span aria-hidden="true">→</span></button>
					</form>
				</section>
			)}
		</main>
	)
}

export default App
