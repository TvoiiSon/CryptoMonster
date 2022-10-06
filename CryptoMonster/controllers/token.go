package controllers

import (
	"CryptoMonster/cryptomonster"
	"fmt"

	beego "github.com/beego/beego/v2/server/web"
)

type TokenController struct {
	beego.Controller
}

func (c *TokenController) Get() {
	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))

	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)
	fmt.Println(contract)
}
