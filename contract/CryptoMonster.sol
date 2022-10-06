// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

contract CryptoMonster {
    //Роли
    enum Role {
        OWNER,
        PRIVATE,
        PUBLIC,
        INVESTOR
    }
    Role currentRole;

    enum Phase {
        SEED,
        PRIVATE,
        PUBLIC
    }
    Phase currentPhase;

    uint256[3] tokenPrices = [0, 750000000000000, 1000000000000000];

    //Структура пользователей
    struct User {
        string username;
        string contact;
        bytes32 passwordHash;
        bytes32 secretHash;
        Role maxRole;
        Role currentRole;
        uint256[3] balances;
        bool exists;
    }

    //Структура заявки
    struct getRequest {
        string name;
        string communication;
        address sender;
        bool reviewed;
        bool accepted;
        bool exists;
    }

    //Маппинг для работы с блэклистом
    mapping(address => bool) blacklist;

    // Маппинг и массив для работы со всеми структурами ПОЛЬЗОВАТЕЛЕЙ
    mapping(address => User) users;
    mapping(string => address) userLogins;
    string[] userLoginsArray;

    //Маппинг для работы со всеми структурами ЗАЯВОК
    mapping(address => getRequest) Requests;
    address[] requestsArray;

    //Модификатор для работы функции только в SEED фазе
    modifier onlySeedPhase() {
        require(currentPhase == Phase.SEED, "You can only do this in seed phase");
        _;
    }

    //Модификатор для работы функции только в PRIVATE фазе
    modifier onlyPrivate() {
        require(currentPhase == Phase.PRIVATE, "You can only do this in private phase");
        _;
    }

    //Модификатор для работы функции только в PUBLIC фазе
    modifier onlyPublicPhase() {
        require(currentPhase == Phase.PUBLIC, "You can only do this in public phase");
        _;
    }

    //Модификатор для работы функции только текущим провайдером
    modifier onlyCurrentProvider() {
        require(uint256(users[msg.sender].currentRole) == uint256(currentPhase));
        _;
    }

    //Модификато для функции, которую может вызвать только OWNER
    modifier onlyOwner() {
        require(users[msg.sender].currentRole == Role.OWNER, "Only can do it Owner!");
        _;
    }

    //Модификатор для функции, которую может вызвать только PRIVATE PROVIDER
    modifier onlyPrivateProvider() {
        require(users[msg.sender].currentRole == Role.PRIVATE, "Only can do it Private Provider!");
        _;
    }

    //Модификатор для функции, которую может вызвать только PUBLIC PROVIDER
    modifier onlyPublicProvider() {
        require(users[msg.sender].currentRole == Role.PUBLIC, "Only can do it Public Provider!");
        _;
    }

    //Модификатор для проверки, находиться ли пользователь системы в BLACKLIST
    modifier blacklistCheck() {
        require(!blacklist[msg.sender], "You aren't allowed to do this, you're in blacklist");
        _;
    }
 
    /////////ERC20/////////

    //Возвращает адрес отправителя транзакции 
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes calldata) {
        return msg.data;
    }

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        uint256[3] memory temp1 = [uint256(0), 0, 0];
        uint256 bal = 10000 * 10**18;

        _balances[0xaaa1e9b82788c50de7f3db580538aaf301f3ece0] = bal;
        users[0xaaa1e9b82788c50de7f3db580538aaf301f3ece0] = User(
            "Owner",
            "owner@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.OWNER,
            Role.OWNER,
            temp1,
            true
        );
        userLogins["Owner"] = 0xaaa1e9b82788c50de7f3db580538aaf301f3ece0;
        userLoginsArray.push("Owner");

        uint256[3] memory temp2 = [uint256(0), 2000000, 0];

        // 0x50fb7d5eb37d3e3bc8bb1751e0a860cadd9d1919
        _balances[0x50fb7d5eb37d3e3bc8bb1751e0a860cadd9d1919] = bal;
        users[0x50fb7d5eb37d3e3bc8bb1751e0a860cadd9d1919] = User(
            "Private",
            "private@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.PRIVATE,
            Role.PRIVATE,
            temp2,
            true
        );
        userLogins["Private"] = 0x50fb7d5eb37d3e3bc8bb1751e0a860cadd9d1919;
        userLoginsArray.push("Private");

        uint256[3] memory temp3 = [uint256(0), 0, 6000000];

        // 0xc1edc3405dc84d383163e50500f9e7e57ce04565
        _balances[0xc1edc3405dc84d383163e50500f9e7e57ce04565] = bal;
        users[0xc1edc3405dc84d383163e50500f9e7e57ce04565] = User(
            "Public",
            "public@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.PUBLIC,
            Role.PUBLIC,
            temp3,
            true
        );
        userLogins["Public"] = 0xc1edc3405dc84d383163e50500f9e7e57ce04565;
        userLoginsArray.push("Public");

        uint256[3] memory temp4 = [uint256(600000), 0, 0];

        _balances[0xa3e533e5e9d358fbc36b518a657c55720f00fa45] = bal;
        users[0xa3e533e5e9d358fbc36b518a657c55720f00fa45] = User(
            "Investor1",
            "inv1@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.INVESTOR,
            Role.INVESTOR,
            temp4,
            true
        );
        userLogins["Investor1"] = 0xa3e533e5e9d358fbc36b518a657c55720f00fa45;
        userLoginsArray.push("Investor1");

        uint256[3] memory temp5 = [uint256(800000), 0, 0];

        _balances[0xccf2f74f37daea093c773b7cf229756d19881305] = bal;
        users[0xccf2f74f37daea093c773b7cf229756d19881305] = User(
            "Investor2",
            "inv2@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.INVESTOR,
            Role.INVESTOR,
            temp5,
            true
        );
        userLogins["Investor2"] = 0xccf2f74f37daea093c773b7cf229756d19881305;
        userLoginsArray.push("Investor2");

        uint256[3] memory temp6 = [uint256(400000), 0, 0];

        _balances[0x9d53ad79b7d8e1c8925310e5a908133274976235] = bal;
        users[0x9d53ad79b7d8e1c8925310e5a908133274976235] = User(
            "Best friend",
            "inv2@gmail.com",
            0x1841d653f9c4edda9d66a7e7737b39763d6bd40f569a3ec6859d3305b72310e6,
            0x64e604787cbf194841e7b68d7cd28786f6c9a0a3ab9f8b0a0e87cb4387ab0107,
            Role.INVESTOR,
            Role.INVESTOR,
            temp6,
            true
        );
        userLogins["Best friend"] = 0x9d53ad79b7d8e1c8925310e5a908133274976235;
        userLoginsArray.push("Best friend");
    }

    //Возвращает название токена
    function name() public view returns (string memory) {
        return _name;
    }

    //Возвращает символ токена
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    //Возвращает кол-во десятичных знаков, которые использует токен
    function decimals() public view returns (uint8) {
        return 12;
    }

    //Функция возвращает общее количество токенов
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    //Функция возвращает баланс пользователя
    function balanceOf(address account) public view returns (uint256[3] memory) {
        return users[account].balances;
    }

    //Функция покупки токена
    function buy(uint256 amount) public blacklistCheck {
        require(currentPhase != Phase.SEED, "You can't buy tokens in SEED phase");

        if(currentPhase == Phase.PRIVATE) {
            require(Requests[msg.sender].accepted, "You aren't allowed to buy private token");
        }

        uint256 amountToPay = amount * tokenPrices[uint256(currentPhase)];
        require(_balances[msg.sender] >= amount * tokenPrices[uint256(currentPhase)], "You don't have enough tokens to buy tokens of current phase");
        _balances[msg.sender] -= amountToPay;
        
        //Покупка токенов у провайдера текущей фазы
        address provider = userLogins[userLoginsArray[uint256(currentPhase)]];
        _transfer(provider, msg.sender, amount);
    }

    //Функция передает заданное колличество токенов и передает на указанный адрес
    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    //Функция возвращает число токенов, которые он еще может снять с моего счета
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    //Позволяет пользователю, который запрашивает определенное колличество токенов с моего счета, 
    //делать это многократно до максимальноразрешенной суммы
    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    //Функция выводит средства, позволяя контрактам передавать токены от вашего имени
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        //address spender = _msgSender();
        //_spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    //Функция передачи токена
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        User memory fromUser = users[from];

        require(fromUser.balances[uint256(currentPhase)] >= amount, "You can't transfer more then you have on your balance");
        users[from].balances[uint256(currentPhase)] -= amount;
        users[to].balances[uint256(currentPhase)] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    //Позволяет пользователю многократно выводить средства с вашего счета до максимально разрешенной суммы
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    //
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    // Функция создания нового пользователя (по умолчанию инвестор)
    function createUser(
        address addr,
        string memory username,
        string memory contact,
        bytes32 passwordHash,
        bytes32 secretHash
    ) public {
        require(!users[addr].exists && !users[userLogins[username]].exists, "User already exist");

        uint256[3] memory balances = [uint256(0),0,0];
        userLoginsArray.push(username);
        userLogins[username] = addr;
        users[addr] = User(
            username,
            contact,
            passwordHash,
            secretHash,
            Role.INVESTOR,
            Role.INVESTOR,
            balances,
            true
        );
    }

    //Функция берет адрес пользователя
    function getUserAddress(string memory username) public view returns (address) {
        return userLogins[username];
    }

    //Функцкия авторизации пользователя в системе 
    function authorizateUser(
        string memory username,
        string memory password,
        string memory secret
    ) public view returns (bool success) {
        User memory user = users[userLogins[username]];

        require(user.exists, "User does not exist");
        require(
            keccak256(abi.encodePacked(secret)) == user.secretHash && keccak256(abi.encodePacked(password)) == user.passwordHash,
            "Wrong password or secret"
        );

        return true;
    }

    //Заполнения маппинга адресами пользователей
    function buyPrivateToken(
        address addrUser,
        string memory usname,
        string memory communication
    ) public returns(bool success) {
        //Проверка на корректность ввода
        User memory user = users[userLogins[usname]];
        require(user.exists, "User does not exist");

        //Заполнение маппинга структурами заявок 
        Requests[addrUser] = getRequest(
            usname,
            communication,
            addrUser,
            false,
            false,
            true
        );
        requestsArray.push(addrUser);

        return true;
    }

    
    // function getApplication(address sender) public view returns (getRequest memory) {
    //     return Requests[sender];
    // }

    //Добавление пользователя в whitelist
    function addToWhitelist(address sender) public onlyPrivateProvider returns(bool success) {
        Requests[sender].accepted = true;
        Requests[sender].reviewed = true;
        return true;
    }

    //Отмена заявки пользователя из whitelist
    function deleteUserInWhitelist(address sender) public onlyPrivateProvider returns(bool success) {
        Requests[sender].reviewed = true;
        return true;
    }

    //Добавление пользователя в blacklist
    function addToBlacklist(address sender) public onlyOwner returns(bool success){
        blacklist[sender] = true;
        return true;
    }

    //Удаление пользователя из blacklist
    function deleteUserInBlacklist(address sender) public onlyOwner returns(bool success) {
        blacklist[sender] = false;
        return true;
    }

    //Функция для проверки начата ли фаза покупки приватного токена и в случае
    //если продажа не начата, то начинаем фазу продажи 
    function startPrivatePhase() external {
        require(users[msg.sender].currentRole == Role.PRIVATE, "Only private provider can start private phase");
        require(currentPhase == Phase.SEED, "You can start private phase only from seed phase");
        currentPhase = Phase.PRIVATE;
    }

    //Функция остановки фазы покупки приватного токена
    function stopPrivatePhase() external onlyPrivate {
        require(users[msg.sender].currentRole == Role.PRIVATE, "Only private provider can stop private phase");
        currentPhase = Phase.PUBLIC;
    }

    //Функция, которая берет роль пользователя в системе
    function getUserRole(address user) public view returns(Role) {
        return users[user].currentRole;
    }

    //Функция, которая берет текущую фазу в системе
    function getCurrentPhase() public view returns(Phase) {
        return currentPhase;
    }

    //Функция для изменения стоимости токена
    function changeTokenPrice(uint256 newPrice) public onlyCurrentProvider {
        tokenPrices[uint256(currentPhase)] = newPrice;
    }
}

