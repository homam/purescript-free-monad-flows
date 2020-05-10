# PureScript Free Monad Demo

Example of a simple PIN flow:

```purescript
demoPinFlow :: Free FlowCommandsF Unit
demoPinFlow = do 
  phoneNumberSubmission <- Flows.submitPhoneNumberFlow
  pinNumberSubmissionResult <- Flows.submitPinNumberFlow phoneNumberSubmission
  setSubscriptionStatus $ toSubscriptionStatusResult pinNumberSubmissionResult
```

## Setup

1. Make sure you have a recent node installation
```bash
nvm use v12.16.1
```
2. Install [PureScript](https://www.purescript.org/)
```bash
npm install -g purescript
npm install -g spago
```
3. Clone this repo and run 
```
spago install
yarn
yarn start:dev
```

Open the program in your browser [localhost:8080](http://localhost:8080/)


## Project Structure
Everything is in `src` directory.

Start from `index.ts`.

`index.ts` imports `Main.purs` and handle the control flow to PureScript's `main` function.