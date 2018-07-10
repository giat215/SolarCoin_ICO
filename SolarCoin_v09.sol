pragma solidity ^0.4.21;

/**
 *  SolarCoin is an ICO built over the Ethereum Blockchain.
    The main goal of this ICO is to build a community of users who
    want to invest in the construction of shared photovoltaic solar plants.
    The ICO is used for crowdfunding and management of the plant
    
 */

contract StandardToken {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) private returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) private returns (bool success) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) private returns (bool success) {
        /*allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;*/
    }
    function allowance(address _owner, address _spender) view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) private allowed;
    uint256 public totalSupply;
}

contract SolarCoin is StandardToken {
    // Crowdfunding section
    event NovaUsinaCriada(uint indexed _usinaID, uint256 indexed _tokenAmount);
    
    // Dados dos Clientes
    struct Client {
        address addr;
        string cpf;
        string nome;
        uint uID;
    }

    // Dados das Usinas
    struct Usina {
        uint ID;
        uint numClients;
        uint initialTokenAmount;
        uint solarTokens;
        mapping (uint => Client) clientes;
    }

    mapping (uint => Usina) private usinas;
    mapping (address => Client) private bancoClientes;
    uint public numUsinas;

    string public name;
    uint8 public decimals;
    string public symbol;
    
    address public fundsWallet;
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    uint256 public minimalTokenAmount;    // Menor saldo de token possível para um cliente

    // Construtor
    constructor (uint _initialSupply) public {
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        name = "SolarCoin";
        decimals = 1;
        symbol = "SLC75";
        fundsWallet = msg.sender;
        unitsOneEthCanBuy = 10;
        minimalTokenAmount = 1;
    }

    function newUsina (uint _tokenAmount) public returns(bool res) {
        require(msg.sender == fundsWallet);
        require(balances[msg.sender] >= _tokenAmount);
        uint usinaID = numUsinas++;
        Usina storage u = usinas[usinaID];
        u.ID = usinaID;
        u.initialTokenAmount = _tokenAmount;
        u.solarTokens += _tokenAmount;
        balances[msg.sender] -= _tokenAmount;
        emit NovaUsinaCriada(u.ID, _tokenAmount);
        return true;
    }


    function newClient(string _cpf, string _nome, uint _usinaID, address _client) private {
        Client storage c = bancoClientes[_client];
        c.nome = _nome;
        c.cpf = _cpf;
        c.uID = _usinaID;
        c.addr = _client;
        Usina storage u = usinas[_usinaID];
        u.numClients++;
        u.clientes[u.numClients] = c;
        u.solarTokens -= balances[_client];
    }

    // Lista atributos da Usina
    function statusUsina (uint _usinaID) public view returns(uint _initial, uint _solarT, uint _vendidos, uint _numClients){
        require (_usinaID <= numUsinas);
        Usina memory u = usinas[_usinaID];
        _initial = u.initialTokenAmount;
        _solarT = u.solarTokens;
        _vendidos = u.initialTokenAmount - u.solarTokens;
        _numClients = u.numClients;
    }

    // Lista atributos de clientes
    function statusClient (address _client) public view returns(uint _usinaID, uint _saldo, string _nome, string _cpf) {
        Client memory c = bancoClientes[_client];
        _usinaID = c.uID;
        _saldo = balances[_client];
        require(msg.sender == fundsWallet);
        _nome = c.nome;
        _cpf = c.cpf;
    }

    function transferToUsina (string _cpf, string _nome, uint _usinaID) public {
        require(balances[msg.sender] > minimalTokenAmount);
        Usina storage u = usinas[_usinaID];
        require(balances[msg.sender] < u.solarTokens);
        newClient(_cpf,_nome,_usinaID,msg.sender);
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

}
