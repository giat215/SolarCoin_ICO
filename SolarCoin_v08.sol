pragma solidity ^0.4.21;

/**
 *  SolarCoin is an ICO built over the Ethereum Blockchain.
 	The main goal of this ICO is to build a community of users who
 	want to invest in the construction of shared photovoltaic solar plants.
 	The ICO is used for crowdfunding and management of the plant
    
 */
contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
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
		uint cpf;
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
    uint256 public minimalTokenAmount;	  // Menor saldo de token possível para um cliente

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


	function newClient(uint _cpf, string _nome, uint _usinaID, address _client) private {
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
	function statusClient (address _client) public view returns(uint _usinaID, uint _saldo, string _nome, uint _cpf) {
		require(msg.sender == fundsWallet);
		Client memory c = bancoClientes[_client];
		_nome = c.nome;
		_cpf = c.cpf;
		_usinaID = c.uID;
		_saldo = balances[_client];
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

    function transferToUsina (uint _cpf, string _nome, uint _usinaID) public {
    	require(balances[msg.sender] > minimalTokenAmount);
    	Usina storage u = usinas[_usinaID];
    	require(balances[msg.sender] < u.solarTokens);
    	newClient(_cpf,_nome,_usinaID,msg.sender);
    }   
}
