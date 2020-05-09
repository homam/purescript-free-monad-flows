var Main = require('./Main.purs')


Main.main({
  uiGetPhoneNumber: () => new Promise(resolve => {
    document.getElementById('get-mobile-number').style.display = 'block'
    const handler = e => {
      e.preventDefault();
      resolve(document.getElementById('get-mobile-number-input').value)
      document.getElementById('get-mobile-number-form').removeEventListener('submit', handler)
    }
    document.getElementById('get-mobile-number-form')
      .addEventListener('submit', handler)

  })
  , uiGetPinNumber: () => new Promise(resolve => {
    document.getElementById('get-mobile-number').style.display = 'none'
    document.getElementById('get-pin-number').style.display = 'block'
    const handler = e => {
      e.preventDefault();
      resolve(document.getElementById('get-pin-number-input').value)
      document.getElementById('get-pin-number-form').removeEventListener('submit', handler)
    }
    document.getElementById('get-pin-number-form')
      .addEventListener('submit', handler)

  })
  , uiSetPhoneNumberSubmissionResult: ({tag, values}) => () => {
    console.log('uiSetPhoneNumberSubmissionResult', { tag, values })
    switch (tag) {
      case 'NothingYet':
        break;
      case 'Loading':
        document.getElementById('get-mobile-number-status').innerHTML = 'Loading ...'
        break;
      case 'Failure':
        document.getElementById('get-mobile-number-status').innerHTML = values[0]
        break;
      case 'Success':
        document.getElementById('get-mobile-number-status').innerHTML = ''
        console.log('uiSetPhoneNumberSubmissionResult Success', values[0])
      default:
        break;
    }
  }
  , uiSetPinNumberSubmissionResult: ({ tag, values }) => () => {
    console.log('uiSetPinNumberSubmissionResult', { tag, values })
    switch (tag) {
      case 'NothingYet':
        break;
      case 'Loading':
        document.getElementById('get-pin-number-status').innerHTML = 'Loading ...'
        break;
      case 'Failure':
        document.getElementById('get-pin-number-status').innerHTML = values[0]
        break;
      case 'Success':
        document.getElementById('get-pin-number-status').innerHTML = ''
        console.log('uiSetPinNumberSubmissionResult Success', values[0])
      default:
        break;
    }
  }

})()