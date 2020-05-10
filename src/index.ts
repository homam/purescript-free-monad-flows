const Main = require('./Main.purs')
// import * as Main from "./Main.purs"

function doDom<E extends HTMLElement, R>(id: string, f: (e: E) => R) {
  const element = document.getElementById(id) as E;
  if (!!element) {
    return f(element)
  } else {
    throw `Element not found. ID = # ${id}`
  }
}

function show(id: string) {
  doDom(id, element => element.style.display = 'block')
}

function hide(id: string) {
  doDom(id, element => element.style.display = 'none')
}

function addEventListener(id: string, event: string, listener: EventListenerOrEventListenerObject){
  doDom(id, element => element.addEventListener(event, listener))
}

function removeEventListener(id: string, event: string, listener: EventListenerOrEventListenerObject) {
  doDom(id, element => element.removeEventListener(event, listener))
}

function setContent(id: string, content: string) {
  doDom(id, element => element.innerHTML = content)
}

Main.main({
  getPhoneNumber: () => new Promise(resolve => {
    hide('get-pin-number')
    show('get-mobile-number')
    const handler = (e: Event) => {
      e.preventDefault();
      resolve(doDom('get-mobile-number-input', (element : HTMLInputElement) => element.value))
      removeEventListener('get-mobile-number-form', 'submit', handler)
    }
    addEventListener('get-mobile-number-form', 'submit', handler)

  })
  , getPinNumber: () => new Promise((resolve, reject) => {
    hide('get-mobile-number')
    show('get-pin-number')
    const handler = (e: Event) => {
      e.preventDefault();
      resolve(doDom('get-pin-number-input', (element: HTMLInputElement) => element.value))
      removeEventListener('get-pin-number-form', 'submit', handler)
    }
    addEventListener('get-pin-number-form', 'submit', handler)

    const change_handler = (_e: Event) => {
      reject() // call reject() to go back to getPhoneNumber()
      removeEventListener('get-pin-change-number', 'click', change_handler)
    }
    addEventListener('get-pin-change-number', 'click', change_handler)

  })
  , setPhoneNumberSubmissionResult: (rds : RDS<string[], string[]>) => () => {
    console.log('setPhoneNumberSubmissionResult', rds)
    switch (rds.tag) {
      case 'NothingYet':
        break;
      case 'Loading':
        setContent('get-mobile-number-status',  'Loading ...')
        break;
      case 'Failure':
        setContent('get-mobile-number-status', rds.values[0])
        break;
      case 'Success':
        setContent('get-mobile-number-status', '')
      default:
        break;
    }
  }
  , setPinNumberSubmissionResult: (rds : RDS<string[], string[]>) => () => {
    console.log('setPinNumberSubmissionResult', rds)
    switch (rds.tag) {
      case 'NothingYet':
        break;
      case 'Loading':
        setContent('get-pin-number-status', 'Loading ...')
        break;
      case 'Failure':
        setContent('get-pin-number-status', rds.values[0])
        break;
      case 'Success':
        setContent('get-pin-number-status', '')
      default:
        break;
    }
  }
  , setSubscriptionStatus: (status: any) => () => {
    console.log('setSubscriptionStatus', status)
    hide('get-pin-number')
    show('tq')
  }

})()

type RDS<E, R> = {tag: 'NothingYet'} 
  | { tag: 'Loading' }
  | { tag: 'Success', values: R }
  | { tag: 'Failure', values: E }