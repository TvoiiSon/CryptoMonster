package controllers

import (
	"CryptoMonster/cryptomonster"
	"fmt"
	"math"
	"math/big"
	"strconv"

	"github.com/FISCO-BCOS/go-sdk/core/types"
	beego "github.com/beego/beego/v2/server/web"
	"github.com/ethereum/go-ethereum/common"
)

var address, _ = beego.AppConfig.String("contract_address")
var contract = cryptomonster.GetContractUsingAddress(address, "0x50fb7d5eb37d3e3bc8bb1751e0a860cadd9d1919")

type MainController struct {
	beego.Controller
}

type LoginController struct {
	beego.Controller
}

type SendApplication struct {
	beego.Controller
}

type ApplicationOperate struct {
	beego.Controller
}

type PhaseOperate struct {
	beego.Controller
}

type BlackListOperate struct {
	beego.Controller
}

type LogOut struct {
	beego.Controller
}

type BuyTokens struct {
	beego.Controller
}

type TransferYourTokens struct {
	beego.Controller
}

type ChangeTokenPrice struct {
	beego.Controller
}

type GetBalanceUsers struct {
	beego.Controller
}

func (c *LoginController) Get() {
	c.TplName = "authorization.tpl"
}

func (c *MainController) Get() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	balance, err := contract.BalanceOf(common.HexToAddress(address))

	fmt.Println(balance[0], balance[1], balance[2])
	c.Data["seedBalance"] = balance[0]
	c.Data["privateBalance"] = balance[1]
	c.Data["publicBalance"] = balance[2]

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}
}

// Функция обработки авторизации
func (c *LoginController) Post() {
	c.TplName = "index.html"
	username := c.GetString("username")
	password := c.GetString("password")
	secondpassword := c.GetString("secondpassword")

	c.Data["uname"] = username
	c.Data["pass"] = password
	c.Data["secondpass"] = secondpassword

	_, err := contract.AuthorizateUser(username, password, secondpassword)
	if err != nil {
		fmt.Println("Login error on user " + username)
		c.TplName = "error.tpl"
		return
	}

	address, err := contract.GetUserAddress(username)
	if err != nil {
		fmt.Println("Login error on user " + username)
		c.TplName = "error.tpl"
		return
	}

	c.SetSession("address", address)
	c.Redirect("/main", 302)
}

func (c *SendApplication) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	username := c.GetString("name")
	contact := c.GetString("contacts")

	c.Data["uname"] = username
	c.Data["contact"] = contact

	_, _, err := contract.BuyPrivateToken(common.HexToAddress(address), username, contact)
	if err != nil {
		fmt.Println("Error on a buy Private Token")
		c.TplName = "error.tpl"
		return
	}

}

func (c *ApplicationOperate) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	uname := c.GetString("uname")
	action := c.GetString("action")

	userAddress, err := contract.GetUserAddress(uname)
	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		return
	}

	var receipt *types.Receipt

	if action == "accept" {
		_, receipt, err = contract.AddToWhitelist(userAddress)
	} else {
		_, receipt, err = contract.DeleteUserInWhitelist(userAddress)
	}

	errorMessage := receipt.GetErrorMessage()

	if errorMessage != "" {
		fmt.Println(errorMessage)
		c.TplName = "error.tpl"
		c.Data["error"] = errorMessage
		return
	}

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}

	c.Redirect("/main", 302)
}

func (c *PhaseOperate) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	action := c.GetString("action")

	var err error
	var receipt *types.Receipt

	fmt.Println(action)

	if action == "start" {
		_, receipt, err = contract.StartPrivatePhase()
	} else {
		_, receipt, err = contract.StopPrivatePhase()
	}

	errorMessage := receipt.GetErrorMessage()

	if errorMessage != "" {
		fmt.Println(errorMessage)
		c.TplName = "error.tpl"
		c.Data["error"] = errorMessage
		return
	}

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}

	currentphase, err := contract.GetCurrentPhase()
	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}
	fmt.Println(currentphase)

	c.Redirect("/main", 302)
}

func (c *BlackListOperate) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	uname := c.GetString("uname")
	action := c.GetString("action")

	userAddress, err := contract.GetUserAddress(uname)
	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		return
	}

	if action == "add" {
		contract.AddToBlacklist(userAddress)
	} else {
		contract.DeleteUserInBlacklist(userAddress)
	}

	c.Redirect("/main", 302)
}

func (c *LogOut) Post() {
	useraddr := c.GetSession(address)
	c.DelSession(useraddr)
	c.Redirect("/", 302)
}

func (c *BuyTokens) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	amount := c.GetString("amount")
	n := new(big.Int)
	n.SetString(amount, 10)
	n.Mul(n, big.NewInt(int64(math.Pow(10, 18))))

	balance, _ := contract.BalanceOf(common.HexToAddress(address))
	fmt.Println(balance)

	amountInt, _ := strconv.Atoi(amount)
	amountToBuy := big.NewInt(int64(amountInt))
	_, receipt, err := contract.Buy(amountToBuy)

	errorMessage := receipt.GetErrorMessage()

	if errorMessage != "" {
		fmt.Println(errorMessage)
		c.TplName = "error.tpl"
		c.Data["error"] = errorMessage
		return
	}

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}
}

func (c *TransferYourTokens) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	to := c.GetString("to")
	amount := c.GetString("amount")

	amountInt, _ := strconv.Atoi(amount)
	amountToTransfer := big.NewInt(int64(amountInt))
	//addressToTransfer := common.HexToAddress(to)
	getAddress, _ := contract.GetUserAddress(to)

	_, receipt, err := contract.Transfer(getAddress, amountToTransfer)

	errorMessage := receipt.GetErrorMessage()

	if errorMessage != "" {
		fmt.Println(errorMessage)
		c.TplName = "error.tpl"
		c.Data["error"] = errorMessage
		return
	}

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}

}

func (c *ChangeTokenPrice) Post() {
	c.TplName = "index.html"

	var contractAddress, _ = beego.AppConfig.String("contract_address")
	address := fmt.Sprintf("%v", c.GetSession("address"))
	contract := cryptomonster.GetContractUsingAddress(contractAddress, address)

	changePrice := c.GetString("price")
	price, _ := strconv.Atoi(changePrice)
	priceInt := big.NewInt(int64(price))

	_, receipt, err := contract.ChangeTokenPrice(priceInt)

	errorMessage := receipt.GetErrorMessage()

	if errorMessage != "" {
		fmt.Println(errorMessage)
		c.TplName = "error.tpl"
		c.Data["error"] = errorMessage
		return
	}

	if err != nil {
		fmt.Println(err)
		c.TplName = "error.tpl"
		c.Data["error"] = err
		return
	}
}
