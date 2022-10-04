// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// interfaceをimportする

contract PriceConsumerV3 {
// コントラクト名
    AggregatorV3Interface internal priceFeed; 
    // interfaceの宣言

    constructor() {
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    /**
     * 最新の価格を返す
   　*/
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/, // roundのid、roundidは毎回記録される
            int price, // 最新の価格をint型のpriceに代入
            /*uint startedAt*/, // roundスタートしたタイムスタンプ
            /*uint timeStamp*/, // data更新のタイムスタンプ
            /*uint80 answeredInRound*/ // どのroundで更新されたか
        ) = priceFeed.latestRoundData(); 
        // interfaceで作ったpriceFeedオブジェクトを利用
        // 今回欲しいのはpriceだけなので、その他はコメントアウト。コンマは残しておく
        return price;
        // 最新の価格を返す
    }
}
