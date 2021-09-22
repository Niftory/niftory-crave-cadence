import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Crave from "../../contracts/Crave.cdc"


// This transaction transfers a Collectible to a recipient

// This transaction is how a Crave user would transfer a Collectible
// from their account to another account
// The recipient must have a Crave Collection object stored
// and a public NiftoryCollectionPublic capability stored at
// Crave.CollectionPublicPath

// Parameters:
//
// recipient: The Flow address of the account to receive the Collectible.
// withdrawID: The id of the Collectible to be transferred

transaction(recipient: Address, withdrawID: UInt64) {

    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        log("hello world")
        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&Crave.Collection>(from: Crave.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the stored Crave collection")
                
        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipient's public account object
        let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(Crave.CollectionPublicPath).borrow<&{Crave.CraveCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collectible collection")


        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}