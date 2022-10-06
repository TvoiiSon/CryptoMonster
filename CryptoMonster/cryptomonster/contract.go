package cryptomonster

import (
	"log"
	"strings"

	"github.com/FISCO-BCOS/go-sdk/client"
	"github.com/FISCO-BCOS/go-sdk/conf"
	"github.com/ethereum/go-ethereum/common"
)

func GetContractUsingAddress(address string, from string) *CryptomonsterSession {
	// configs, err := conf.ParseConfigFile("config.toml")
	// if err != nil {
	// 	log.Fatalf("Parse config failed, err: %v", err)
	// }

	privateKeyPath := strings.ToLower(".ci/" + from + ".pem")
	privateKey, _, err := conf.LoadECPrivateKeyFromPEM(privateKeyPath)
	if err != nil {
		log.Fatal("Cannot read " + privateKeyPath)
	}

	config := &conf.Config{ChainID: 1, IsSMCrypto: false, CAFile: "ca.crt", Cert: "sdk.crt", Key: "sdk.key", NodeURL: "127.0.0.1:20200", GroupID: 1, PrivateKey: privateKey}

	client, err := client.Dial(config)
	if err != nil {
		log.Fatalf("Client dial failed, err: %v", err)
	}

	instance, err := NewCryptomonster(common.HexToAddress(address), client)
	if err != nil {
		log.Fatalf("Deploy CryptoMonster failed, err: %v", err)
	}

	cryptomonsterSession := &CryptomonsterSession{Contract: instance, CallOpts: *client.GetCallOpts(), TransactOpts: *client.GetTransactOpts()}

	return cryptomonsterSession
}
