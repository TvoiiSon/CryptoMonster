package routers

import (
	"CryptoMonster/controllers"

	beego "github.com/beego/beego/v2/server/web"
)

func init() {
	beego.Router("/", &controllers.LoginController{})
	beego.Router("/main", &controllers.MainController{})
	beego.Router("/token", &controllers.TokenController{})
	beego.Router("/application", &controllers.SendApplication{})
	beego.Router("/application/operate", &controllers.ApplicationOperate{})
	beego.Router("/phase", &controllers.PhaseOperate{})
	beego.Router("/addtoblacklist", &controllers.BlackListOperate{})
	beego.Router("/logout", &controllers.LogOut{})
	beego.Router("/buytokens", &controllers.BuyTokens{})
	beego.Router("/transfer", &controllers.TransferYourTokens{})
	beego.Router("/changeprice", &controllers.ChangeTokenPrice{})
	beego.Router("/balance", &controllers.GetBalanceUsers{})
}
