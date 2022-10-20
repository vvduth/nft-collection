import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import { NFT_CONTRACT_ADDRESS, abi } from "../constants";
import React, { useEffect, useRef, useState } from "react";
import Web3Modal from "web3modal";
import { Contract, providers, Signer, utils } from "ethers";
import { Provider } from "@ethersproject/abstract-provider";
import {
  ExternalProvider,
  JsonRpcFetchFunc,
  Web3Provider,
} from "@ethersproject/providers";

const Home: NextPage = () => {
  // connecwallet tracking
  const [walletIsConnected, setWalletIsConnected] = useState<boolean>(false);
  const [preSaleStarted, setPreSaleStarted] = useState<boolean>(false);
  const [preSaleEnded, setPreSaleEnded] = useState<boolean>(false);

  // waiting for transaction to get mined
  const [loading, setLoading] = useState<boolean>(false);

  // check if the current account is the owner of the contract
  const [isOwner, setIsOwner] = useState<boolean>(false);

  // tokenIdsMinted keeps track the number of tokenIds that have been minted
  const [tokenIdsMinted, setTokenIdsMinted] = useState("0");
  // Create a reference to the Web3 Modal (used for connecting to Metamask) which persists as long as the page is open
  const web3ModalRef = useRef() as any;

  // get provide or signer based on the paream
  const getProviderOrSigner = async (needSigner: boolean = false) => {
    // connect to metamask
    const provider = (await web3ModalRef.current.connect()) as any;
    const web3Provider = new providers.Web3Provider(provider);

    // throw error if user is not connected to the goerli network
    const { chainId } = await web3Provider.getNetwork();
    if (chainId !== 5) {
      throw Error("Please change network to goerli.");
    }
    if (needSigner) {
      const signer = web3Provider.getSigner();
      return signer;
    }
    return web3Provider;
  };

  // preSale mint
  const preSaleMint = async () => {
    try {
      const signer = getProviderOrSigner(true) as any;

      const nftContract = await new Contract(NFT_CONTRACT_ADDRESS, abi, signer);

      const tx = await nftContract.presaleMint({
        // value signifies the cost of one crypto dev which is "0.01" eth.
        // We are parsing `0.01` string to ether using the utils library from ethers.js
        value: utils.parseEther("0.01"),
      });
      setLoading(true);
      await tx.wait();
      setLoading(false);
      window.alert("You successfully mineted a Token!");
    } catch (e) {
      console.error(e);
    }
  };

  const publicMint = async () => {
    try {
      const signer = getProviderOrSigner(true) as any;

      const nftContract = await new Contract(NFT_CONTRACT_ADDRESS, abi, signer);

      const tx = await nftContract.mint({
        // value signifies the cost of one crypto dev which is "0.01" eth.
        // We are parsing `0.01` string to ether using the utils library from ethers.js
        value: utils.parseEther("0.01"),
      });
      setLoading(true);
      await tx.wait();
      setLoading(false);
      window.alert("You successfully mineted a Token!");
    } catch (e) {
      console.error(e);
    }
  };

  const connectWallet = () => {
    try {
      getProviderOrSigner();
      setWalletIsConnected(true);
    } catch (e) {
      console.error(e);
    }
  };

  const checkIfPreSaleStated = async () => {
    try {
      const provider = getProviderOrSigner() as any;
    const nftContract = await new Contract(NFT_CONTRACT_ADDRESS, abi, provider);
    
    // i guess when we call the thign taht aint funton we need _
    const _preSaleStarted = await nftContract.presaleStarted()
    if (!_preSaleStarted) {
      
    }
    } catch(e) {

    }
  }
  const startPreSale = async () => {
    const provider = getProviderOrSigner() as any;
    const nftContract = await new Contract(NFT_CONTRACT_ADDRESS, abi, provider);
    const tx = await nftContract.startPresale();
    setLoading(true);
    // wait for the transaction to get mined
    await tx.wait();
    setLoading(false);
    // set the presale started to true
  };
  return <div className={styles.container}></div>;
};

export default Home;
