#import "@preview/payqr-swiss:0.4.1": swiss-qr-bill
#import "@preview/zero:0.5.0": num

#set text(font: "Noto Sans", size: 14pt)

= Recharge de la carte prépayée Carbu SA

#v(1cm)

#image("carbu.jpg", width: 100%)
#let src = sys.inputs.at("data", default: "default.json")
#let data = json(src)

#let name = data.at("name", default: none)
#let zipcode = data.at("zipcode", default: none)
#let street = data.at("street", default: none)
#let building = data.at("building", default: none)
#let city = data.at("city", default: none)
#let number = data.at("number", default: none)
#let amount = if data.at("amount", default: "").find(regex("^\\d+$")) != none {
  float(data.at("amount"))
} else {
  none
}

#if (name != none) [
  *#name*\
  #street #building\
  #zipcode #city\
]
#if number != none [
  Compte prépayée numéro : *#number*\
]
#if amount != none [
  Montant à recharger : *CHF #num(amount, math: false, digits: 2, group: (size: 3, separator: "'"))*]

#place(
  bottom,
  dx: -2.5cm, // Extend beyond left margin
  dy: 2.5cm, // Extend beyond bottom margin
  swiss-qr-bill(
    language: "fr",
    account: "CH2380808008998915797",
    creditor-name: "Carbu SA",
    creditor-street: "Route de la Chassotte",
    creditor-building: "5",
    creditor-postal-code: "1762",
    creditor-city: "Givisiez",
    creditor-country: "CH",
    currency: "CHF",
    reference-type: "NON", // QRR, SCOR, or NON
    font: "Liberation Sans",

    debtor-name: if (name != none) { name } else { "" },
    debtor-street: street,
    debtor-building: building,
    debtor-postal-code: zipcode,
    debtor-city: city,
    debtor-country: "CH",

    additional-info: "Prépaiement " + number,

    amount: if (amount == none) { 0 } else { amount },
  ),
)
