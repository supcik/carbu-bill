#import "@preview/payqr-swiss:0.4.1": swiss-qr-bill
#import "@preview/zero:0.5.0": num

#set text(font: "Noto Sans", size: 14pt)

= Recharge de la carte prépayée Carbu SA

#v(1cm)

#image("carbu.jpg", width: 100%)
#let src = sys.inputs.at("data", default: "default.json")
#let data = json(src)
#let name = data.name

*Payé par* :

*#data.name*\
#data.street #data.building\
#data.zipcode #data.city\
Compte prépayée numéro : *#data.number*\
Montant à recharger : *CHF #num(float(data.amount), math: false, digits: 2, group: (size: 3, separator: "'"))*

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

    debtor-name: data.name,
    debtor-street: data.street,
    debtor-building: data.building,
    debtor-postal-code: data.zipcode,
    debtor-city: data.city,
    debtor-country: "CH",

    additional-info: "Prépaiement " + data.number,

    amount: float(data.amount),
  ),
)
