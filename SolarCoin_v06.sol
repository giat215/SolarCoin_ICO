pragma solidity ^0.4.21;

/**
 *  SolarCoin is an ICO built over the Ethereum Blockchain.
 	The main goal of this ICO is to build a community of users who
 	want to invest in the construction of shared photovoltaic solar plants.
 	The ICO is used for crowdfunding and management of the plant
    
 */
contract SolarCoin {

	// Events
	event Transfer(uint indexed _fromUsinaID, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event NovaUsinaCriada(uint indexed _usinaID, uint256 indexed _tokenAmount);
	event TokenTransferido(uint indexed _from, address indexed _to, uint256 indexed _value);

    // Token usefull constants and mappings    
	string private name;
	uint8 private decimals;
	string private symbol;
	uint256 public totalSupply;
	mapping (address => uint256) private balances;
	mapping (address => mapping (address => uint)) private allowed;

	// Crowdfunding section

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

	// Construtor
	constructor (uint _initialSupply, string _tokenName, uint8 _decimals, string _symbol) public {
		balances[msg.sender] = _initialSupply;
		totalSupply = _initialSupply;
		name = _tokenName;
		decimals = _decimals;
		symbol = _symbol;
	}

	function newUsina (uint _tokenAmount, uint _passwd) public returns(bool res) {
		require(_passwd == 12345);
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
	
	function newCliente (address _client, uint _cpf, string _nome, uint _usinaID) private {
		Client storage c = bancoClientes[_client];
		c.nome = _nome;
		c.cpf = _cpf;
		c.addr = _client;
		c.uID = _usinaID;
		Usina storage u = usinas[_usinaID];
		u.numClients++;
		u.clientes[u.numClients] = c;
	}	

	// Lista atributos da Usina
	function statusUsina (uint _usinaID) public view returns(uint _initial, uint _solarT, uint _vendidos, uint _numC){
		require (_usinaID <= numUsinas);
		Usina memory u = usinas[_usinaID];
		_initial = u.initialTokenAmount;
		_solarT = u.solarTokens;
		_vendidos = u.initialTokenAmount - u.solarTokens;
		_numC = u.numClients;
	}

	// Lista atributos de clientes
	function statusClient (address _client, uint _passwd) public view returns(uint _uID, uint _saldo, string _nome, uint _cpf) {
		Client memory c = bancoClientes[_client];
		_uID = c.uID;
		_saldo = balances[_client];
		if(_passwd == 12345) {
			_nome = c.nome;
			_cpf = c.cpf;
		}
	}

	// Token section ERC20

	function transfer(address _to, uint _cpf, string _nome, uint _usinaID, uint256 _value) public returns (bool success) {
        Usina storage u = usinas[_usinaID];
        require(u.solarTokens >= _value);
        newCliente(_to, _cpf, _nome, _usinaID);
        u.solarTokens -= _value;
        balances[_to] += _value;
        emit Transfer(_usinaID, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) private returns (bool success) {
        /*uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        */
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) private returns (bool success) {
        /*allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        */
        return true;
    }

    function allowance(address _owner, address _spender) private view returns (uint256 remaining) {
        //return allowed[_owner][_spender];
    }

}
