interface ILendingPoolAddressesProviderV1 {
    function getLendingPoolCore() external view returns (address payable);
    function getLendingPool() external view returns (address);
}