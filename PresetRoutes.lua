AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

DR.PresetRoutes = {
	ragefirechasm = {
		{ name = "Default", exportString = "DR1:nQ5ZU11noy8xL8cuarQ)F92cm78M7IzTrS70G6Mu44u0bb5DFoxrrXpD5bTtxe4AYF4C0hPOO4XFpD5kF5TN)E(Y16Lp(2lp9(lp)ivB5ykYC7HRLlV(YF(YRF970LhPh(oF5438hF5tF(9VEWC73Cqsx(VpMlu4HJF6VES0O(dxZxE)tV)6lxdxUMU8(l)17Yp9Pp(Lp)y7HF8iViPykpjtn6VNmDqgxKCoWczosP)5NzYEBd6BBSx()GmViRHwBsgZ)ZRZFC4WRF6ZVCOF96uVo(3JLkD8V8dps0XBYXA6XsS0F44v8430ZpC8epSoLPbWWmRMhaCva4dztbIgWnZSAEaqSael1fqYaUzMvZBaPmVaYEGH5bqIeGCSTakgqAUOhMha95AOeSNq1a6Z1WW8nGBPicaNwantwBZNWW8nGCP4b6lGH5nGcpx05sybCeKuIHDwTpiosHezQApcYI1d7SAFquBZirZ0jYc2d7SAFNaekkEcHQuhzmZ0dYI2KfUh2z1(Mur46i71ksxhPB5IdIOLcswaFyNv7rnVpP59kr9VBFHMtrqsibH8CCgbtZngJFZnIk(w19e11BvCU3RbAfBX8HDwTVr0H4btEI(kZDraXCMpHqJ5kbhG4bhDeI9nccYD5KNG0C3fbNGQozpbVuxLicQlx8eX7vxoHQB1tKUxDhv4xenpr(E1LZO62pHyPUZSeUaQBm4Yse7dIIuSIRG6gHyErQwj2XQvCdu3i7kxj23i6G6gJEI(sDNeXaOUXKJqSVrqG6gZEcAPUZvEKa1nwCRCXogpoofcuxFmxSJvgIruDBUkdID8WJycv3U70dX(GOjX8ygu3KfZh2z1(grbu3e5jkQ6UiQG6MyprvvxJau3u8ecvDxenqDtjprtv3frhu3u2t0xQ7Kifa1nvCeIDjEeMe9UrGNMhMe3SJrWewBp1CrqX(ilHLtCsm0Hrc2NZYjoIDmt8OHwtRY(A7IDSYqkbNrLjxLbXoU)iLGE3YSB)Hyh3dMYqZBz)(CX(grjcpd)(CX(obKxLZNqS21QeviVkx8e11UwLOX2(JC1tmSVtGR82jeUvEh6Bn39eDTXvTVKCaYRkbxFjI9rVpbjljtyNRwmFyNv7dIS0NyMH8QIfZh2z1(GOfMeW6OyX8HDwTp6HliD9DuoYYelqpCbPRpX(GipFgritSKDD9DCmyBVRVmEItP466lBN4OQBhYskvV62VV2EUJVv(A7ID8Yn7eD3TBmcojXJsaIGvlMpSZQ9Beupojsw9QQfZh2z1(GiLMeqv0QfZh2z1(nIqUFcHfZh23jO6Ka2rvTy(WoR2Jdzo71Q6kMl2rTk3tQ6c7pQfJiPQ7C)rUtZ9hDitSwncAU)OpZeZ9W8TQb7pQnJimFRAZ9h5wFMLuXi4kMl2z1(grbwhTGNOORJfrg2d2iprEUhm3QtTkb1RASruNAvAwVYiW9GTONiQXdJau3w6ecvDxey1Nw2tWl1vjWkCTINGCQlwfTv9AvyLLmJ5BvQB(y(Qs9kVA70Gw3LxTon4Om0805kOUDlMpSZQDmBpvb1TtUSDX(gXr1pJG9ed77eqxF94jeb(oIm0zzp5jYu9oIeuPUN9ePiDhre6HR73Nl23IhmuVQ73Nl23jcGw1oHiuUJa76RFsmNC5vbiVIcbFIvyTTDM8g7qIff870fhWDiXgKzD7oq3VfrCqqctKemCIaUxpmrsAfOYjD7tbyZE5U29ZTuZFLcka72tT97uyi49wOqXJOxCj3Ij)LJOaSFpM2VDKHKQ4tP5rgoSJafUOq)eKvLlfjcvUik4rIX7vmghAer(LpVozqJ(eMJrNe9PvowB(IrueqGOFB(InCylTe7hGOKpTmuU7GuUVnEXSl5N1(TwpfUH5yuX9u42khBU85gC9cIQULV4aMjZvClg1CzYIdyOKl4wmYh9fhUHuNt(KlyAPnCoXbwDyGmhHlJhYt205ehy1HBifoEgIf9hoSHKxJCAdXI(51mNuKuEgkZq9yYgqxMMTdUgHu(wXejUG7xSj0joWQd3qcP6jrFBeDIdBr)W8q19CmBgDIdB5yHzv89mzBiDIdBzYleAB539iKEEK(Ifzm6BJPB9IjomqMTdhJyPpBoDIdS6akYX0201zNilomqiD4tOiBtQtCGvhgiX5E)mkYri6hN79ZQiVqkOihZEKYkHrrQOiBdRZqQQiVqABIC1J0urEPyTT1sZRyTvcJgx6BXLv0pvM3BmPFFHuzEVX02xKWgyN4WgsMRNHSI(IdBiP5nhtBFfdBKDIdS6WnKyUnrWpJHnZoXbwD4gcx15PHjm2q7ehy1HBotT(ziROV4WoYQtPnKIHS6usrcC4KMRS52joGnxf7ZVT0DiROV4W5iBFghBYDgI21NHGZ6JSr3zi6W(meCyFKn7odrN234da7M2hzdVtCah3xS3z)4(iB6DId48(sHqXpVpYgFN4aoWpdPGISn)odPmfzdPIISnapdPofzl6x3wlROFSnN8vQplxeR68r7yfgBeEIdBifDqV7iw0VOt61qOZEk2q8eh2qY8CxzhJ(2u8ehy1H44tdK83)KSX4joGxaD8D)femT0MJN4aRoCdH1nYBISnipXb8sRhhNnx(nSYVnjpXbwDydzxXkEKLIPihhJIl)QdrCydHWY42W8meAE8QHW4XR208meEE8kGG1XSX5biT2DirSYVnppdjoR8BijuKTb6ziPLiRdcBRfoBIEIdS6WarNe2whSvi6RJct7G9OXK5WAQOiBZ0tCGvhgiZR8KBOiBd1tCGvhgiZUXZBnkAt1tCaNwCKMLl2M9lzJ1tCah(Bm0z)iqjBUEId4mqJHzp)LTgfTb7joWQdBiBnkAt2Zq0gfnKTgfTr7ziAJIgYwJI2S9meTrrabfzB4EaY9ICzRrXw2jYfTrXinVlwzRrXge9N3fROnkgP5LelBtvObr)5Lel11UYzYFzR3YwZL8xQRK)Y8P0WJxHj8nIG7nkoRwECynOyWi(cZQLIddK5t5q1bfdMX3WbwD4Mw170j9Wyd5tCa7Hj1N7x2Bu0MYN4WwJInT7IT2rTX8joS1oATpr2(d3XMZN4aRomqc9ZqSZ9R6H4lKY6dPUHyD9vwFjvfjx052zNID8FxlxE6BV)RF5TRX0L)1NE95F6NF6TF73)Yx(8h(PpC9LN(6XpqHp8VpS8XNE75R1lF7pE29hAyw(dn84r)JB)jj(5d3(5x(LN(2RVF8)(8VDLIxE7P)Zl)YNE7Lp(Rp91F)kD5pV58)7d" },
	},
	deadmines = {
		{ name = "Default", exportString = "DR1:nY1YU2XXT2Ff)deGMSEF0udKzAYzqglyDU4kyfPaz5GCHH)3VDxfFSyxTTZGiOiYL37ISEqUQvT)T8lVYV8Tp(BLxET9Yp9T3(W3F7JVNA9skNPXX7ET(YNF7F)2N)LFJF5907o)ZxlV85p9L3o)hooM)tLR)89CQvo)Z39(E58psN)1Cz8U3Np)hsNMN2(9Z)N6(0klwVCVKZl3PdZ9K5(0klwNU34L7xFCI7z39lR4xM6XXY9rXCVyUpTYI1P7L609r1)YuD3VSYI1P7T1)1PJS)F(M7FB9F(L5aacco9DaKgD0VqetndWy7B0YmoGjU7FcNbV7d5LDmIsjo7iOTy6YoMYOu1)sr8wsBzFoNOLwiYqwM8080oR2V(7P(4beEMEApIGgp8TYt2t7HVvCv(wLo8jtKNVN2z1EabMoO2oclFyiWmo13ryPCU12NurEoFApmRkDu2M1YEkFAgN2MYRpHEZt4mSIoV(aMMNzVJ02sugwsNlsQqhcZ)Y1qOaHjgs3x2z1EarfsfCEhrvtfzsct1E3r4P7PDwTJddQHJBpDpTZQ9aIogzB7i6AO1qmoNDBi67iM2JiGPT84be2IjbbFa7bMo2qSSJlMyk5XQeTTyAzpGGHnfs8ocw3uWqKWnYt7is3xIZPQhRs5hqut3qKH5vPYoISoVYquG5vP6oIYX9yvbMxLApGOFpwvH5vP(oI695vCdMxL2Z5l7beDytH8d58UUPGHyaB8KPDedBvRSIkDar3mVTIAzpGGGOBoTJGoUvCqIGOBoVvEWY(8WgADcyIXt89C(0oR2NikKGao0p758PDwTpr0LpJeS(i758PDwTppMLYcc4y2mCsoLfe6XS186y2ugwrLHJYZRJzx2Vq0ifbSZqXZ5t7SAFIOSoiivG1GfpNpTZQ9jIHKblq0T458PDwTFH4SeXfIkmlP458PDwTprmKVvnywsXZ5t7SA)cXGLpJgmlP458PDwTpruKyfEMwXZ5t7SAFIOk5C8uZINZN2z1oIiFa7Tx6Biw2JiWm44beAgCKw5Jmb5JQNZN2z1ogRYmm3TsBXQL9z(OVwFKXc(QEoFANv7yopJfJv3Z5zRymhbSgSMFaHUg0quoxuyik7iM2diWAgQ1DewndocyEvT9aI(9yfwZqTVhRSAgSmyhZhJ9myxZh2SKoSxs7yFwsx3lzmw7(KhqgSb58XA3NL9RjJhvfbmYBwoFzNv7xiiE1irbRYOz58LDwTprmibbKZBzhXGeesopDw97cbwxsZY5l7SAFIOkFgegRQoIQ8zqsSkLKZOkm2JMLZx2z1(eH0SsbRKP1DesZkfTsMu(GFaHLZpbmUHOlRAlmKp6woFzNv7xigm)aclNVShrm49rE3Z5t74ipF00yfmVQB58LDwTFHG08bdRb7woFzNv7xiMFyBiSC(YEarkD8aclNVShqKLtNJiSC(YEeXO)aIUJ4YEarPNEi6A58L9q0TMg7ZsgwoFzhNLCUnKeDtWkQb5iKDFw2Vq0oKpJmS(yy58LDwTpriNCwkWzudpN3Ktox2xiKpJkdJJmGq(mM2NiKD4kyfYdpN3KD4kAfYocSc5rDhHwHCULKmiwH8WZ5t7SAFgDRYS9oSIA458PDwTpZ5s1sfSM6bKZLQLkAn15Iudxza7IshEsVifXTCyovukuSILHthEwplvkw16WT571diADvZ99j8lhMlQKsERyP70HN3tsnVvYwhk0(uXA3PdpXNeEFQAX7NDTlFkmK4PdpZNKQ3xomHi7LwtHXcSC)qg(jBSOqYiJjhTDizn3BqkiTmh9DifnvAJLAiVm2hlALV2oxvSYxYzJZ26Q2UVzxfl9LC64aiwqwHG1(soFCoKUfKviyXVeL2HmSGSaPfOLIYBqAhwqwHe4(Ik7qiliRqceSr7B2347b5wGfpQTdjDFM85EcyqUVntE5WeIWsAlhglq2xOjTPSGLZcvSTmMxCI5woWQdtic)WnK4mIH1(cdXnL5SCr65RvGAOiNEULdS6aEq0niPTtICinPELwbNW4e0D(1jjqKjmLZUMfiit0odDlhy1HlijzRVgwrp5u0TCGvhUGK5MabzV25OB5aRoCbPq0tqSS)YHiKUcjW49WH0viYPKLQCcwd71GCA6woWQdxqAfj73cSKBz)LdS6WfKEsMj3WZxCI6woWQdxqgcp5nSLgYzQB5aRomHimC1640sNQULdS6q66GMIcbNW4C1TCGvhUGq6czSRgYjRB5aRoCbHLd(UbXY(lhIqKk9UbP7qKs9CijPuV2aNw681TCGvhUGK15yHiMty3YHqeZG0WDyCg7Cinzhghsf3t2PSZHuL9KDiHfYoNDoeDH855SJh2hZjTB5aUpwnLPh2T0zTB5aUBznjvkf3t2PTB5aUNCLLlhRfU5QmK9LRhRLSSplz)W1JLHSplzF9(XolIvpsc3T0zUB5aRomNjRNVqyeZPUB5aRomxVinD2iCTVZD3YbwDycry4nEIStE3Yb8e5YqAxlEUFbw7l9RzN7xgYLfvhN1G5qG1(Y1fTCycjLKcsWnLC(7woWQd4Ms1w4Y7QBBkTCiaPIPsNbphsvpFXGugyeRVdPmk3glLqEzSpwuov9GmY0l5K45bzLQxhcsan5S45qugODiil3ufY(YvMvzDj2rxsLKeKZti(A)PdS6aot2AtybjVnt2AtOsY5(wZiliE2VN7XpLsRjqOqeZZ(thy1HjeMFOLhNlVLdylp2jYLriI13orE5W8CFH66qdFufo3x4U264B1M89(qjNoVLdyJONfOL2B2LC(8woGD7E(pm27OMCc9woGTu7qWl2ICg9Ci6nBbqWd(Ck9aiA9ygKmqJl5C65qYcpUoeKLdYj1ZHKg3JyZccniT9i20HqEHdd)(EErjq78aWXoPqKZR3YbKvOsvztHWZ97qvFkDkePt(p67eTsDOQVJEKPvB9sGnxYP2ZwVy05w6IoeYdCAPZT3YbwDa35)gK9D(niR9C2Hu22uYHqsN43glqvFsN42yPssVyLJGMk8Z9jPxSLdZdXZ8o30uho3pZrYPTcfleUQSp2kuC5WSgMszN)uYP4B5asGQvBzHXd(Co(SAlxoGLWf4rKg7v9zejEw9x6HLydOQpB9Io8Z66fKjrYP5B5asLOdPeglLDifBSOqQ4KFNOphsTW3G0WZkDM(CinTESSUdtpKx8SFw3HPR5flipcb5XEqEq3Z(duFjhpK9h3Rtg5673FT(Y)6RF6lF)x(TKi0UxPx()UO0i)UZ)2)zP4MxlV89p99p)2RhV8A(LV)2)57R)2N(PV(L5rUSHSKoxgmrE(nO(NJSRYVBISDD9CtK5bF8xI83NFQ8l(iOGJGArhb01eP)YVh(iiF1L0c54CM6FkskmcoB6G1rq6)IpZSHmXAuBwJ3FjYIJCOFBNBr(xg1mPvEolgKw5zd29iPcelB8hyiWw4VmJ8dq8rFNFGKd4OhzhGiLON2tcSCzoa4qjtcBB1wYVmJnTo0MPrQuS17dTtADipu6TqYAS16dLBlLPMHshes6KToFOCbPmo17sJA41uBRXNwz16L7kDdH2ATf4DLSbTP2wxBqT1EqALTU2EABnyBkLzHgAT8BtjmtBNTjushBn1sVnHqARX0MCwBdvxGtHBtoPTPIlOknm0oEusLvPDHMkFb1)6apZOE3)Lz0)EOYVn)v956(JBk339xM(RXNAlSV)94ZYme)RviE6e2QX)Lzy(WCJTDLuQZhwMV8p)WTo4u12Z3UZHUqhCnJAC0YVDHm4Lzy2FOZtNKwD6V13jDqARQOSlHvVK2P6HUCVt7xpJZq7YoE7mejLehAu1jODzNv74MwRox3erPTRL1z75Us6Tzb1D60ZUSZQ9jcHR1q)Jo7Sl7y7JelsOiC8Uto7YoE6UTBD4cgt7BxBxWiGaLRy6beA(Wq0qjrM3r0OBNHuQq01jM1ruTORkKGceDDEzx2z1EAkyAPv7mgD9C(0oR2dispkIshrsJUPuEVHoNu2LDSFokvt79Z5CYUSJTZrzHWOGavCkzx2rbQqzHQ8qJgoJSl7yFgurLBsaHNZlQCtme1s)beEoVw63q0Yp0wQth7Yo2v6zZKThg5EoVl7L4J8HwXm2VKtg7Yo2U0zPXJhq4IR6qBV2ricFkIWfx1Hi8jhb1EOloqeLu7wtCNDM9q0ferjNVfDn93h6hferPkaFRDutb(H(KbruMU3zTjY4mEFkLDXsNDPONEq6AGikvj17sxtFLgb5XbIOuFLgU84kAZ74fqaIOSO9UR3)axKl5jiApqeLf5oECr7PIZnJ3wjiIsvCU5Ijox5EbIIp8y7vZ4IpSjZ2Zzu2LGWzLz7l7tHbkZ2ZyPGOikLz7z7rr4YUefFy6bzx2Vlmq8fTaIO0egO(IwshjfbkjsxqDhjfHeDpNAE8acFD(qBM(qL25rrjSr(wLIIO8OO81OIALyokxXuueLeZr5kYK(TsfrzkkIssoD2frPHq7BjffrPHqBCHjnwvHXbiIssJvvBCi1LK1MlsbruUSZQ9qSsVp)uqeLESsVo)v8EdrElF4i69uC9rkiIYLDC9b1LEQIJdyVDPRkBCyNgKRqg0PB1oniR9HrD568YANQPGikx2z1(8mkHVTCtw1McIOCzNv7beDyC4CT6i624GEyURt1Q)TsN7s96iU3EkiIYLDCVDAOKnD08yLt06YoR2Ni0BziGaeo7rnUxY6FzUQn7XkNMvhrsf1QHGRE(Wzz1rWY5hocc)w12rO3HPJ4O7ZeDowDehQevpKklJiCHZY65G2NrsKpAgVAvNH1L9aISEItaHlC2SEIJHOiT1feHVZV6Yokc)urNjIkDYPxDzNv7xiQ6Q2acpNx1vTgIMUZqaHNZB6odgIoPzq4wsCUvx2z1(eHEItyK758UEIJnYh6(UbeEoFO77QiYhjn6IYG1fs1rsJUQmyvzjF2eA(rruQ6sE5WeIOf90azgber5Hig9LdtPmlvXLc3AniIsskJlP3ADMK2dsHBTgerjj9hK0BTotsLFPWTwdIOKKP8j9wRnnwNc3AniIsvK1j9wRbi0ZIO0HOb5R7OB79jHIOKKh6T9aLCiHBTgerPbjzbzfchcYJDiSfKviegKbruAqiliRd)dmidIO0g(hwqwYlC4YHbruQ5fEybzj7ZHRiG2Z(8WcYYCmoCreGik15yC3Mjlt(5W1DaIOuN8Z61D4qcxQciIsds1cY6xSWv3aIO0(IzYa3g(HlicerPn8Z3NjZHRHcerPMxytq70tpRuueL093vAMLx8bhUsnqeLS8Kpy9k1ShLq45UIIOuFvc27Dnpzv4(BQffr50b8r1AkiMdxcjN3uqmRTwAkvn8wFbruAkv1ESVMStPWfQ6u0zYoL0lu9SRg5xzGXZIOC5aRomHimNt9G6oHxmHqEoPfFzAHN6Hi2ytl8KwvV9ilOOwfp2ELf2B22e3k9hiIstCRuZEMfs9xuqgDorDlhy1b8vteEV6OikjrEJ2ZpFrQ0(yXVoDwAw2glfwkDH(der5Yb8bOxy9xZHWnW7K1TCGvhMQU9XjmoBDlhWjmLKiJooCd8oDDlhy1HjeHlBoOmcNVULdS6WuBVK8eMd6VWjSB5aRomHu0fYbve6IPix0fY6yjx1DycYB0ftrUQ7WO5f7tj)Sik9pfLFZssQq88yThfr5YbwDieXc7j7S25rmDpzta1Cn8RMXUaQxoGzFUIBkL3Z(lhW5yXJKCI7S5y2rsNJjzFSwq3LE2N19XAQy90j)CpC5thBt(xoKMp6p9q8GWd9Sp11dXvP0qcNxPdCS4K3zcBF5qasqTAGikniMA1i9zVZbveM32Uy5qesqRILhGO5fdskOiY6oe9vP7qYHGCBhs2cYkKsii33HuSGScPgcYJDivliRqA)bIO0G0SGSMxc3oiiIslVO3pOTNCQ)SikT9KtDBYVmTmfVJZ020Y0WMjl81hEg4GikTxcH9oWlC)HgXqruY9BDIz7jhEi4Oik19KTxcUTdt4LGJIOu3HXEk427TiWIjkIs99wy0yAV3IBqgBV3cacx2zLmiIsUejY0Keyo(tZZUikZ6lhYKeyOJ6GikV3sT9qqYbnxJIOuzX10CTcj8dnqqeLDk(lnG9fl8RzqqeLYxm7NZalihN8JIOucY(K)Si(Oy3RGikZIi9TUxljPqXZtclpkIYKuO4Yb8iPunm8hBhjTCaNjNWRvhfrPotoPxSUdjhuriTdjFVgMuovEueLoKu5gKWgSGikniP7pPP424GikTHVTnUfKdhw0l7bz7WIKunE8iPoS2xQg3psslijEWxVTvqIFWNU2pE8AFFTVF8QvPu4qCNHpVsj7qCvoWriJJn5a7quH6g7e354ZeQR1jUju3y)(ojFMqDT(9n9JhzvWz5Z0pUXQqP2pEG7cNMVLdi3fLQCfNrgsCE(woGmKuAPh(5Rber5YbKhMsteZqKTNbiFErndgBpL2G3wI97t1k(HF97)VF9BVMYV83)0N)4F7h)W3(5)5x)6x(H)2p86BF4xo)l0Xp8poT8tF4BF812l)6)6JB)Cdww)CdE9FZRFyc)YPB)4B)pF4x)83p))(XF(1XlF8Tp8X)5Lk5ELE5FFjYV)))" },
	},
	wailingcaverns = {
		{ name = "Default", exportString = "" },
	},
	shadowfangkeep = {
		{ name = "Default", exportString = "" },
	},
	blackfathomdeeps = {
		{ name = "Default", exportString = "DR1:vYzZo3rUnA4BL(giasu)qPpVnaZoVXlM1EA)fmgTJDdB3bzGHV3N6i(3RoQM0z2e4yYhxhjkXs6LS6FuF5D0lF9d)O9Y74x(1V(67)(RF4TzE0k1kL6V5D9x(0R)Jx)03(r5L3MFZpOxU(B(9V8Xp)9VDX(4V5Im)Y)ZBZjQ(MR)0)8T1wF(M31E57F87F613LE5D1x((R)ZVl)Pp(RF5ZVT(MF(wYjBKrwOu7Fn54IS4Kx)gBczotL)CYQtwNDwiB0O)Ns(Zlh(0h)8RF7huM1r91)7BR9z7nxdLRr)y8MRFzVTYTR)V1R)M8J)WYQoyxalZKz(bWineGR)PDGIdSmtM5fqljaLu8eQbWdZKzEbW6tO84hPc0cawFcfBmmj9ju5Qd0DGLzYmVa6fbO1toahapmtM5fWmla9RiObmcGhMjZ8fqlLNkamgMgGyMmZlGklaCj7a5uq8Woz2xeCtigqGiNdcwJ1dns0YjDypHir2d2IDYSViQ6ZycdJCjiQ6ZyAJdJGsqSixpie7BeziyKBNeznAeeuUee9tIL9DIomxX3q05NikW(I84KO0S5QMeYPAbMRIy(Yoz23iAumxrPtIL9nIEoMRO8jXY(oXmw5s0neZ2te8iwjsLtIL9nIbm7s1tIHp7AetmRt7Ky6ZUzz)rjbZUeeZZY(dXoU)OKXzx(y)Hyx2dMucCCmG9GjLWghPK(mimEa7Zt6ZGYwMKsvjGrEjfPsEyNm7R0HDJaIGLiN(Yoz2x5079BiGK6pSVr0h5B(vfz1x23(v1BLZrEjsRVSVnY7u7C2Te51x2Xz31lMfciFvjsSVStM9he1HoxLGCjLiZ(Yoz2xef9xvIbIi1(Yoz2Fqug6SBc2Fu8yUyNm7lISsKH3EuJy(Yoz2FqqdD1EEodIiMVStM9fHUJAlcwJyoP7OIiiz7OkWoQAeZjBhvr3rvZd9zuHDu1iMVStM9fHThSbRsQrmpB7bB2QKCxxj2G1U1iMVStM9nIoepQ8jr3Ihz9DTfUapJiMN131k2xefD1odVhSgX8LDYSViSmdd49GTiMNTmdd7qjj9qjLjS2TfX8KEQeX(IqZLutW7bBrmpP5se7lIuxjG9GTiMVStM9hqtwMDRzc(v5XCXoz2xef9zKXrElik6ZiRJ8YmPpdIGFv9GiPpJL9hednd31gHiM38yUyNm7lIIKBVwG1UTrquKC7I9he8SPe4CLhZf7KzFr01NrfwT3tbrxFgvD1EH1CIxxmi212ZbHMtuS)GOpTNbS)O7XCXoz2xen9z0G959sq00Nrt3NxAAw0AhY72JyEtZIk2xe0qjG5QEeZx2jZ(IiPJdgNRIy(Yoz2FquzsjW5QiMVStM9frvhhmoxfX8LDYSVi0m11boxfX8QMPwS)GyDjKfbSsKJy(Yoz2xeAM6R7LeRe5iMx0m1I9fHMP(6AdW1vIyErZul2xe6j9Bj42eCeZt6LUAjBKN0R1T)mIyEsVxN)mOPThCBC4XCXoooOPEM6RRWbpJEqONPwSViOIsa3XH5GGkkHEhhAy7A5EKtK9yUyNm7f7qPpVsKNbrN3xjsdBxBhg5Juqy7A72iNN6ZObRsgEmxStM9fHE2NTDTdki0Z(47AjUMpZmmkbrnVNzG4mDM9zudImTN9H6wMbmd3iI5DlZGLHJ6T(zw0reZx2XSOu3YLGzQhrmVB5sSm1u3YLGVnyeX8ULlXEBa1SmdOigJiM3SmdMkguvprwf1jzgX8QEISQjucvvLvQzyUAgX8QkTIyFrO7Z3E78mI5vDFU)2zQON956f3WVQiMx0Z(i2xeLBoLXmI5LYtNYGk2jzMWC1mI5f7KmtBU6AYqp7doxfX8LDYS)GipPZZxnJy(YoE(kktgbCM6zeZx2jZ(dIuXo1hSUAgX8LDYSxEiQHDhhg1lj5bDXbYC4bYWUYYoIh1fh2qy7ol7iEyxCyhjxph8puVXrY19rFURN)56qiGcijpWloqMdpqAA66Nq8iV4Wgs1ol(oIh6fh2qkmFhIh7fh2rS7qJN4pNgbIDjA7i)5IEW3TRvKtZarp5RFVImzRjBOswHKCx3SvcLntEMR)gbP1yusUmGqkcRNdI0DxToQ7xikN4azouw35tMKB8MWFXB3ZQCKIdBidCnwilxGmSJ0L14sBGs)f6YjoqMdle9gmT52mwCOUSEfgXHfIMQOJxyphkZjoqMdBizu9VqAUajRx7bqW1yH2CaID(0S(20ob37jhIZjoqMdleDzzNWHFOoN4azoSHuWHFipxGu8HVk2DVI79ji6RYDloSH0W1yu9eP5RXYffzGpfi6NlkYWEk6wSEh1)KGOVUftCyDOZ5urMOG0r0F5azoiiYwS(wQVqKoXbYCyHO1tOp2g(r0pPvuqCyHOAU1X35Ldz6ehiZHfsJve4WT5qNoXbYCOyNc)cHtWBKYHqD(X0fhwi1IIGzykWj7RffXYWK07JZzC4xGJ2RxixCyHqtfbZwgA1joqMdcIexycxjhI1joqMdBifmuw4tKIhkZnfb0flxGOFUPiQWy(fBy8qU5Y84MnSFhBhbp7DUMor8Rm7ZynCLCnFoJ18vYw0hRPuUEt0VxFAlgJxvjxlhBXy)wZwEmgV1CUwpYJX(1MTm)mET5C9mZp73BMuf14X2mwe9jvsn2V4819dveCbtOBN4azoSUvREGegVRDoeUtCGmhqjaEczEObqG0Q0niH0DIdBiDIVdjI(lh2r0BeY4TNZnuihfXLbGvr65jUGjuVtCGmhk2bSxi4lXb57g6LqyRaEU8Ddu6G8n63joSuvuF)YiHRXcb8ehiZHL8OA9rFcbuTvpCvGy6v)eY4qWAarfNzGIAKdn8ehiZHLw9SnJHhvOdI1Z2mMvMIQEf394sOIN4agxUY0yrF88yHmEIdK5WcXwWSTFj0XtCa3Vu7vBlgHJfOinvBlMkSQ0Gah797TJoiW377vBI3QCDiLNxUj2kDDDyVscRoEo0YtCGmhWA8VNTSpoQYVNT0lAp33MKNhLTNnDmBj9(l7z(zOm869x8m)Er152JCVos(OQ6IdyTLzSFfYmDuCz26yHgPxFJR4KCOON4azo8aPOQIWLTAEhLLTOYIWM0lTITsgBvJCOPN4azo8aPQhuKPTzSOWSv9GIIdlevqAgLsjhQ6joqMdle9A1CABSeLMTQxRMnPrA1PDEmmNCORN4azouw3JRPhuex8hc7joqMdlevIGRlAc7kdL9ehiZHneuhICiTxGycr0AAHf6D8SLH2EIdK5GGOd)oEc2qCpXbYCydz7AcH6EbIDnHaz7YiH8EbIDzKaz7kpH(EbIDLN26c4leClwiWN4azoSqg2132AFJi63g213S1yocwZ18mDIyfDfqWH)mFdIp8nKTl8oPtKKp8vK9Rvplhi(1Qbe82RZ6ni0ZpfSjoYZ2jI3fhbcEt8z)geRrCCeEB4ZNi8Zr)gJr)5z0xCaxJ16y0FopwJjoSqktv6gS3psq0VyQ94dFnDrRInktkFKUqCyLuAOkKuWUXj06tCGmhWSLx75Gwmj06ZZwkoG5KxDQyGupYjloSY8p1Y)qqMFk06R1N6wSS1PxSDT6m8sCk06tCydzOce13AxMqRpXbYC4bYSNVdjI(ZEEhPVox6Z79PqRpXbCVFpX6pmSxiOqRpXbYCydbBgck06lqSUHiqABDVfDI08XIwSWoQBjfA9joqMdle90fBz(jOf8665XCXUG8y4I)C7M8ygsxp13ti9)fpfwVW7tir0N1l8ciMApWASFU6pvSXElyJ9UuXqAv2hjD)tBYwOXE5RyR2sWxxk()hn2l)OKAlYr5AFY)(TN719DH2ZvkB7QLn7pvi3RxQuoBp3ayAsDga9BApxaWe60ai8Av1daYUuvaKl30EUbq2lrUbGPJ6NaKxVBdat5XNaLNl3nHPvh3ay6vu0ueB9Qzikqrtq4TQPx0EQoUR9C9I2tvx5HKrGkcfX6LDYSViAdTDqVT9Cf7KzhLQyNOCOurqykvS1YPqDamHk8woTW58ner8EzFNqVdj12UQ2rJZi2xYuOL5NA49bH25rlZVyhf2G2kBY4qxdYRAI1Yq0wvtMhTme5fnXjgBVt8KWRzsq0630EUarR)eXeFLaDsmT16bb(gHYne2IDJyRPib1)ncVPidITwNTDsyToBqS9A6(jb5JdncU1KQG0)we0Bs1Ys6WvdlIN3cBHlTSYfVPV01vLk(gN5X6kX(IWAvZgCWzq3)H1QMnRQpdDF(wzcbz)h6(CXEXQHD12SD0EUIDYSxSkF(Cbpbr)z94SE9olSx6AypiO5p7vU22dY6bGl4nzbj)z98VLXZnVwzaTAdO4V18AIDmxYwReac(B5s8wjO0T2GbBWbqV)U1gmjpdN1UBjypii3V3UBjBpy3ACgSrna1(7wJZynQrPRhWUI1hbe7VRNVU6LhXBPoSfvaT(9wQZByX2Dnodi1F75gNXFBWJVeQBApx)TbI9T22dfIQEtB7z6qvAjRrMG1UvST9SgzYw7w12LER1Naz(RA7s7T(K)EWTMjeu53Epy0mHvR5oXICGI8Bn3z0AGj6S1abn(x23AnWcxoBnqqI)cxEU1a92DdBsv6OAfqRbAnaewuaqGFRr)IwdKSgacf4h03NSgaY133B4a88EG8(E)gKI6bLucCUcQRl)CZeAL1UTDer(OQ2n)mIwbxBzCUACuVvX(wdlsqgU2zz9e7RMjuBHRgbc8ek7l2jZo2IJTYTTNR3IJn7JakiWdwg66he2jldc88vHS(brZBJYHgpWpcOqvFXoz2xetD2f)iG6qRAQxUV1FUCUR7eDt75ALMvSJLZSHF2qq756TCQ9zd5vZ8k33TTNRvmtX(EBSGeZB6IL6tfMC7xf0EUwDjJFve3oNRG2ZL42tZv2Lj2AHhS9C1BteDWJ1MX7eLJ2moiS2LENOE0U0aHPOZgbKBFoEIOBItTreX8UPnLtWUoBibFCUKGWo13oX552dIPTsSdVJkKXxStM9fHVseoVBOIVyhLySmvPS2wxfI4l23wx5etyCeA4hetFCyszKWwonI5tRVvs2zFccq1)r9gcRHsCc8C7J2jHFU9GGVR9Cbc(5FveoY5tc6yKxWr(4KOCmYRWP(gZtIQDQVGaBG00neEDUnc8C7Z8jrZ)aD8gCcBDw64JNrSVrS1KQNFUnEVk5LsFRxLcD79kP7TQunz9229TNRyh7uPAITkJHJdOA9SvymBCyFmt8wBgZhFmtSDk86JEm4O1MMWNyvRU3ztvYQJAcNRGs1BLrnfFKCJBkkyizVxDFVOG1I2dW7TpvizV4a2(u(N7hNqTjcj79V3p2)M6R6bMy8cfq75koqMdRQ771eD7Z)oc8nVMOwG3(cmFcPD8jygiSEd6NqGs1RxHoqgwtATJaLQ3AslhzMURHZsqP6t9NrSQ7VJefSP88mwRAiBXf4lMVAneGfx()OkYWNm)zvKTI1(eYzXAdKUVgdL)c(O57(AmROGSnjVJes2Z2KCGOFxEmEnxO9CfhiZHv1x8zSTXsiz)WNXSXY034Vnjhs2p9D(2K8KVBLm8LZp5Nwj3t2w)8wFddfSX27BFYGEnEy8d4aApxVgpS9fC0t6X)z8k4q75koqMdLvdeB9dbQ9zipN4azoSqSgoBRRlc95ehWUUOtK1HIy6IqGoXbYCOSEtjDttngk0joGn1yVQAV8eIh9fh2rM31NkHgDIdyFQ0B6nnEcXJ(IdBiDEChse9784jewRJ4ositN4WgYW6qX92anI(dRdf9H)0wJT1ZnHqDIdyp3WjBbZwOmuQtCadLC2AtNDep6loSJmVBbtOvN4Wgcnk3H4rFXHnKsNVdXJ(IdBi2N80tiE0NTV5PaP1UD47rFXHnKEPEdsiyN4WoI1ky7i5aXAfmhHR3n8dj7eh2qgEFDDF75koSJ4BXWg1ieTJh(wmv0oEAzy2wwgQ2joGllhjRLw3r8OV4WgsMUB)sOBN4aUFzKhN7k)5Q4JyXAZyXAxfBrkw7JUf4F)cNME56F6R)rF)F89)7V813vQV8F8Xp9H)YF99F93(7F5lF(x(l)Y7E99F76pKt)Y)5LLF99F9dVJF5p(9pC8FXOAY)fJ66x1pF8FBP(8LB)1x)BV)p(03V()(HF7D5(l)xF69)6V93E)1J6V)HxF93)21V4)Xd))Fd" },
	},
	stockade = {
		{ name = "Default", exportString = "DR1:nM5ZUXXnmy8xf)cears93zVgGEZx2d98c7TOgX1oWEtqkm87ENruuKA0aK2dfB2p(dZk(rrXr(d)YzC5Th)iSCoT8WBxVC76J3dPCG8EesNohxE(6pV(87Fal3dN(axw)MV)6tVC79v2TVzLew(37HC0DA9t)6EFXfpDoSC7PBpF9SB5SF521FDJ)0tp86l3Np959yNeXCMjrx297jPojvKNzkwGFpPVtgl)))16p95NRb88tVCDnlqyBvV()xHr3P1LY9XCjCA9xw7B8BFdS(HWMABXUdytEaiH(oanduLhaIuUd4NbQYdaHa2bcZav5baFm1bIZav5bakdDG0mqvEea1Nq(aaC)tatAwQmduLRaR2AfaYAwAnN3j20rrFKWPPjaoGWH7iCGUkaCMOQVrKlyLiuinrbQBx1rrFGi7dkHFMOQpqKIAfieMjQ6vIuMjIMKlOgEvhf9bIGn7MMjcs2vjSz38bes2Tt4Tz3YmHVNDfcYKDr3mb1ZUcbAYUimtG9SRqaMSlIZeWu21zYUint42ND9ft2f9teS(ibzwhHdiODRdF2SLfN9CwFGivmpJzpN1hjS9cZhqa7Yv(OPzio75S(arW0nKM9CwFGWBAhsZEoRpqqM(H0SNZ6deOj7sZEoRpqaMSlDGNdtzxWKDPd8Cyk76Sh1CGN72NDPsY8mM9CwFKWSRLYhqSFxlLJKsm75S(iHzL7DhqSFLt2dz9ZEoLMw5dNYo75uCFDfzpM1p75uyFDfzpN1p75KFFDfzpO1p75eTVUIqtDLF2Zz9rcB29aphNYUGn7EGNd9SB7mkYzZULPZOyDlX6ptZqmUjcwFGiBYUbyMih3D6mMmz3aotK6ZX0MaaJMSBGMMaG1hjmz3G)aI(aIcrWKDdHzIaUB2h0BYUH4mHN2n7ds2SBAMGc7M9brB2nptG9HefcWMDlZeWu21EwBS75bxU0QRANohGenxjg7EoRBRedyqQDnZLe7EoRJI(gb5LAxZ6i29Cwhf9nc)2uSvc76O75Sok6BebaM3Fe7EoRB3FeIUYbeDpN1hjk(diskXM(ars2NpSo6EoRpSoQTSNYUDpN1hYUfOLDbqpniPEEvhf9kreM98K65vDRNhDBLlEPUri6EoRBRRIa5AeMQ9u3ZzDu0Re5yJizi8kro2isncuQRSVXsQ75Sok6BeKKRqZ8UPUNZ6OOxjIcHx9JusjIcHN9JOxQertNHu3ZzDu0ReXwUcnNNNkkrSLRW255XGu7AF5UC3ZzDu0Re52ZGmtzKbLi3EguBkJym2Q2jt1Ew98Qok6BejOv7sRhm1jupVQJIELqQ2jZ(JS65jPANA7pIzXbTNNNvpploOCEEmlv7EZoQS65zPA332rTUnUvT7nv7z1Zls1UVvTNCqR2nyoJk39Cwhf9kHuTBN9jxucPAxM9jbbHWCYzP75Sok6BeO0f1orwP75SUDISewect2TGkrriAz3er48CILUNZ625et1r(ReModfVseBpJuRZqYtP5PxlDpN1TtVM8sN6Sj7w0ZZt4UUO(O8RY2fTONNhLFvsxuFeoOlArpppc76IU(2rPdi0ZZdIF0j8jHW8wQGthIRgakburW8CRAWPtXvdW2R2t9E1di6yCuVzTGGhDGa4054W9NiS(AyXJwl6GC1agwlG)Geg40j5QbmKXCfy2hbNA91agmsh5NpYfCQ3xdWwTqLG7iKU5ZbmI4KbukwKII4KjuknKAX7(5Ma9k54aSdoX7z2pWbO3jhhGDIdkbYmkMU2GEPCCaOeWgsmEWOtGERCCa2jHOqwMDYE3u61YXbGsavek0EbgtdpqVxooaucydX36QU2NYuWOxmhhakbq1ZjYhH0DFoGrei1qS3jPE1CCaOeavNNGocrD)AadiGV9dlBVXq9Y54aqjaQw5uAij71RQUFnaucOI0QKhENpqVEooa7l9HLyljpCbR69ZXbGsau9xi0qS7x0lOJdaLa2qsTJIWHlLvVHooaucOIaYBJoC7YrfbKxhTvJHXw3sC4IC17OJdaLa2qcbbXAL6L0XbGsavK24AdVclO3shkZR1Fh212NnKH7lwVMooaucydHsT9lbRVO3thhakbSHGTUL4WDmRxuhhakburADlrV2uA9)ohxU8JB)9RVDM8l)Xtp)4x(6L3(2)86RVC3xU781lVV(bWD3FUQ8WL3E8CA5hF)XP)2zb(VD26J(ZT)kBVSg2xV(xx(XZ3w)Np(TZ5L3V96dF7YJxpdl)ClS)l" },
	},
	gnomeregan = {
		{ name = "Default", exportString = "" },
	},
	razorfenkraul = {
		{ name = "Default", exportString = "DR1:nUvZoYzUnWxL9fiasu)3Z1fi3MlZHC2y9SigRJ9IXExSjg(DpFFISel1FnItoe4mSQ0TePiPkX(B5BVi3E79FRC7L2TF5TxF3xF99phB9skxATYtVuV9Xx)Zx)4x(w82ZXN(MC74V87F(dF6RF5BT5F5Gz82)(zPooqhV9xpxQs6Pxk3(6h(6hF9LWTxY3(6R)1x1)1h(Lp)PN7p99NLfZubm7LC)hZmTyMZGzR3B)yMz)ZmfBkZCQ8)XNzHwNPOYuII8JzwxmpwMITodHFmX2Iyl2YkXApo(FZm)03)(bGp(Hp96x(M06Ml64)(GCO80X((Znj1F6yB85AtcpDq54VCSD880Q5zMeMMfy(KqnvvcNFLaH0IW0SaZNekhRzLW5)WiKxeMMfy(KqU2mcXWIqzryAwG5tcPHriu91qDryAwG5jbbeeFn0Cccii2Aqk6IUo6XfH(IW0SaZtcHGrG2whoHqWiGT14rm4Kqp5FchlqWyAxG9jJK9r0YfNH7RN2fyFJrD4EIOCLX0(oJZ4fWi9agiEkECYFYO0PVvU7EAxG9jJOT3w4vU7VN2fyFJrMx51RmYRvEqJbpIo9qQO7XN2fyFJHqH5X(vgcIZx7vXoTxnUUxnTVfKeP1HeUgLeX6q6zJrW9GI7ZN2fyFgQxhkJaf5kUpFAxG95XVs6bmCF(0(gJsQzmODxHoINAgdS7wfB3nqXvI7ZN2fyFMNkuFad3NpTVZyengCMn3NpTlW(jJ(r1URmCF(0(gJrr3DlJb5bDF(0Ua7PZuk5SXGtFU85QDb2tZ0CGbD(iT85QDb2NmQjJbLanjoJAYyyzqpYUBm6uSBA5Zv7cSpzufJbLZnLDgvXyyjDBPy0yqr7PLpxTlW(KrbFRo)4bJQZOGVvN2NmgQhS0Oy3uZzmupOA)KrUhmguCvA5Zv7cSFYOyXULzihyS85QDb2NmQMhSs(8S7ZN2fy)KrnbgKpp7(8PDb2pz0c2kVq(JS7ZBwLF1(KrdmOCjz3N3AGHLlPnl9CYit7vz3NpTlW(KrZ8GjU2V7ZN2fy)KXWYTxeED4(8HLBxTpzyvolrYNNDF(WQCQ2pyC07L5Zd0P28YNR2fyFYiB(8aDIkpCgzZNhStu9qt)mYdADucoJM(zO2NmgDJb1usj6mgDJH1vspATXK7K)OS85QDb2NmkQpp3OvEj5mkQpxTpz0tgdYdwYoJEYyyEWUyNZZvELV85QDb2Nme7BvH8GLQZqSVvf4bLKM3D2()IrZzK08UQ9DgCtL9hWaEWfJe7pgxzKG)yXqi)rnCLb6(2x5rQBPA86kp2l3T7gPmdv56UB0Ym0Jwha5aL3Ts(CRda1ohxLgu98A(sCLANJDtC7U1YLy3e63DD(i1PCI16LZhQD(myI7qU2UCgmHoK7bRYzQrv1Q05CRYPAFMljdgKpV652hzWW85RmCPkTx1cxYWP2NmI2UBHIDBEU9PDb2NzQRrJbTYBuU9A0yGQbvR3NuMod28C7vR3h1(KHDpWuMQg08C7v7IGQ9zvTIXG7PU552N2fyNR1oV69Ir9sTw1(KrqJDtcL9P552N2fyN7ziXDH36x6ziHUWx9LK4UWBJl9LKqx4h92yFR4UW7bQ3h7Bf6cVfX5dU71o1dhoFGUxBrlAx4(e7upCw0US6tm0adkkP7(8PDb2NmSATc3dx395bRwRS6Hly3ks4(R6Uppy3ksw9xf62NrJIs6UpFAxG95k3YmSZW95rlZGZqSQA7mCFUyv1Cgjlt9(6G85wMAFDK6DJbD35H7ZN2fyFg7A3ks6uuYW95z7wrQDUZsH7qEix6SuwDixAXREWH7ZN238G4CUWD6pUEoxwD6JCjBXvJYLCjECfYxTf7oQxYx5XURCI85Jr7AoX15Jt1(ugKhC4(8PDb25oltrk3(yCPZs1(w1GiT7gdHRLdIRM4qjhztgN41AoYQkvhuO6bNzowu6GYQPmlGpLyzzcx7JtbWDASLFpgYxA1yLGVldqHLzjqDYnaf05WrvoJcRbsWlRpbiaWjLCOFT4wm0EqwiOBYiH4lQxUyWVO(iHamiry)rHKXGFt9(9XKQwP3htgjj5GyQPlsoKcSaBKMCqZbfWKsRDT6tKeLBcGl)4u2IXiv5wuqm2u04lvEJKSCtaCP3AVdkD(tX1OzcqaawnKuMoHfjH5GCikawoKTgvIX2f9q8ovqfLu(4WRtPFPKIcywsrEumMRnNcyRdkufkvQjsR0WLYqkaweLTg7IU6Clvu8o7Ko6EKJXC55uacaWLUsn(GSRp3Q2LcGvfj14nzxGULSikGzXlCqUZhXCf6uacaWvV26Op6s0TkFTAP)O8eU2W2YVr1VW9gWYhkJKdBl)(fPruaS0iBxak6Q0T0gzDdOvfSm)eersMouclJhHO1SZl5i79jD6A25ffax1llSQ0j6SFnT3i5XvM7xB9mMO3Fb7ylkLr(ALYyIKNDK3lvwlOT7TuFUwDkGTuF5QDEH1on6I1PaeaysjICYB7yUcT5iYjB7yRhUzpnUlx36PB804YQr6cVJrVfZQtA8au4Ty2RVKV(ymE9LqVDTrSORyNcG7etfQEsPujkU3FcqaGZSqdlgBRbXORzNcG7q8W3I(9smLStjJg(sgLoA4RZPXDv7uacamPeQx71n6Y2Pa4MDln5bxLi662Pa4EWl1E4ruwE)5ZoV5kl1hgj7k3Pa4izNc3Ny0LUZPGgfDkchW4A35uelGHOWb)U4Defl4)Oot7bD95Q3Pa4U(kvKgFRiUlFNcGlIxQiDXwrCx)ofaxeF5k3lI7c4TCLRI4LgepOWNklK3hQhuk3fWSxR0LWZ)uQRLp2XQBl)X1DSkw(fOFWw5vxepfaxETucq0i6zkIUkEkabaoXKrd8Sotrxgpfal0ujHRjSve31XtbWfXp6Lj)GI4UqEkaUiErsHRISfDL8uaSkBLzFPxQ77s5Pa46(hvpq3f8Je7A5PaeaysjBUYoFEXfZtbiaqAQSE6bDx4Q5Pa4UlY9vdjBVt8Y7RayPpZD7(l7nK465Pa4gsYTeOWUsxqpfGaajOv(LgsCf9uaCdj56sPy2V4s6Paea4KsbppalGD010tbWkyNZ4vlsBl)L3xbiaWKIakBl)MtrafS8tM2w5mhw6Y6PaeaysXIKZfUHexxpfGaaj8nCsH9(UWEkabaoPiM8VhD3qlFxzpfGaatkj8(i8DKDP9uacaCsjI2rB8Y312tbiaWjLGDjX7O4E)GDjXfL0yyl)ghJ5Q7PaeaysXYjV9wprxEpfa)ypPEbu4uFU(Ekabast55JxFFOOlWNcGFGOJmTGchj7k8Paea4KYr7MxFtPOlXNcGFuPubpYxMRI5A8Paeain19O(iklVVcyNs4rb)UkFkao4xVf)vklVVcyJIyjyZPTXxX9(ILGvbKMQELEWbzxOVeg0G1bzv3JlPlCL(uaC6Iuajyf277s9PaeainvIS9G8yUwFkaop2rp2PRxFtCT(ua813KwD8iklVVcyJsfbm7uwEFfWgLccy404IR1NcGtJlfeWStj7uqaZIsgbm7uwEFfWgLJUmFeLL3xbSrrY9hrz59vaBuIiGHDLIR1NcyZvgB9hrX9(rR3spGjI8yCKS4A9Pa4i5J))lF9GS4A9Pa4dYh7n1RjLexRpfaNu6Wp3UM6tCT(uaCQVJy2X1eSIR1NcGtWghO7coZV4A9Pa4m)hPFgxNlaX16tbWdgWrEX41HpqCT(ua80hCu8XAiPZtwMR1NcqaGtknCeBNYY7Ra2OuXrSnkUwFkGDk4i2oLOtbhXwukXhmTgIR1NcGhxJJlqBrYDEG0CT(uacamPehpyt216tbSTjNWPYnxPR1NcyZvk2enT1DH4A9Pa4UlIr7Y77XyUwFkGTySGPB5wNsIR1NcG7uAytc8Dmwo)HnkWoHO8acUqFt7mHoQ5TTmCz(6OKhwf94J2Qs0u6C3ovR0FGhKggVsF3b2EySinlE3hkwrtRdEUtj59qpRd8KdyWVcBRbAeRTb)kGlfAcvvICGRlTxX0PsTRccyeA8AGUCVnmAt7Z72BFLeolxIUAV9vsWfOT(BoU0lpKQ(f7T2Bu7ZRpJzxJ9dUKELeMDniqJD0RK5C1UGEf7KNAN)e4z2ti58WNaMzV1IUYNujX8WIUUKY0w0n2pKPHR2w0niklgyV22AOEFOHpaLbmhO8ej7Y45hGSyPbuJVmyclp9aIXxSNiRJByUv1Kg(oCbtu0CryRYmn7DGakmViSv9Ng9UXD3hDrGBjvOjVBCxhPlcB99rdEhiG2(CcC0kn3Dlcindiei1KfAS7aHGjMStGDC0u3nUt2I(JMXlHg6U7NXlKBDtljXfSdHglPKgyUZ4FrdIlx3aZDg(fnmGmA8WxjUyDdOIgg(QbEVTc3aQlv3ap3wX6)mgW0bXVOT4k1Pa4x0ogGeI8tTlUsDka(P2JrOgCAB629Q2rOgmK2DvpDtazXvQBvpDjGCuSF6oBpCSuPQ22pEN1dhhtySW2P4vTtyUWwuY4DZ3P4vTZ4DZDk4TM3P49SLXBnVOuWBnZ)(mexPofGaaZE2WBnN2(bbq9SH3AgpcESHhoENI79B4HJxu6iQFZV4k1Pa28lDt5HTNpqCL6ua8Zhe7iqMFKcXvQtbWpsXX9KEW8minQJD5U5z4izu66BNjnQJ9YDp4Y62hBZxK4k1TU9XACooU(B6cLJ)Zl1BV7p(6)8ZV9skF7V)Hp(()2p)U3(T)1N)8N(P)2p9YRV7lh)Jy4N(hhw(L3927FPD7p(93F5hVyr)XlE8r)9ZFMJF6a2p)6V(U)4JF94)57)TxIPBV9U)ZNF7xF9t)2Bh)5xI3(ZtW)3p" },
	},
	scarletmonastery_graveyard = {
		{ name = "Default", exportString = "DR1:nIDtVPXouya4)k5pqLSp2h)XW2k1DSHfD5vOWCV3OsHkGe1iu(V3X(yFSpmwkTlQsYlpaJF9hdC3oTdMUC4ooTZp98L593MpSv7dOXI(OAZo30X53MpE9UEAREZDyA5V8RZVC6217(8FzrQNEFlQnHnl)0V36vw7MD40TxUDCENAAND628VVr)0lpF(02WMp2cS0gQsW40FU0WstKL4FZRPT9UnyXQedFUeBYO3ssJj9C8zs3G3T)Dspl9Qqrg02pzeYU5JpwEahF50817XAfT8)BdkVAZY4(wxWS8RMnB9XGBZIO8xWuAPzsakwcuWAGPbsXcqq7xdSmihlaEJznazqowaC2WAGJb5ybaD21apdYXcGnOwdcmihlbq5AW78mi2aq5AihNbQibCH2RGw1ePCOMleyeBc9AroxkwEIzbmqKYfclyBcZAroxim(Uxd7Aroxk0THknoqOFCSc6AdTBTampowPTDJv(1ICUqOCDxhH1ICEViV9alIReuEsysft6XgwwCZR9ADEohQ5srAzwvOhis5zHJw9H(UrxO155COMNeqSiCDxhqRZZ5qnpl0MIa7Ex168CouZtcnekI(DDADEohQ5jHclcSFSQ155COMNfgvr0pw168CouZfcB)yvyTWwhRyHP)6iUwy4RJY2Ni0DDy4o3fvLXkDzE1Y69Y8kD3mrd35uUq4n2bcUZPCHWHQbcUZPCHaryGG7CkxiS1zIcb35uUqycMbcUZPCPalRpuDZDn(MalRpuL5UoZYPPjHn23hHMiLd1CPOBELjoquMx5apn6AdDxh2wNdLtLP8KqxovoFJrSO156YXYuEwuMxzdDZDTToxxoxMYtcv5CzRV78dBRZvLdMPCtAJRYbZsb35uUqekNmlfCNt5cHVC0SuWDoLleUGAWvo35uE)voILDrLJUCNt59JUiQ1dAWytO1YgeTGFTa5oNYfcJfgi4oNYfcWAhi4oNYfcnglIU7Ya5oNYHAUjVqbhiADEoVxyJr9ab35uUuOCdeUMq5EqeayGG7Ckxi8MW6vTi35uE)QwRdndeCNt5cb6kJUXU7wYXDoLd18KWgSdeCNt5sHsnqanHs9GWODdeCNt5cr(2Mwj4oNYfcDDNbHO1566odSqv3zqiADUQUZqvyIUrJvCNt5crimASI7Ckxi81DgecUZPCHWvUBjHWZDoLlf6bZR86Mq)W8kdcdM765oNYfcBDNbHG7Ckxim1DgecUZPCHaQ7mieCNt5sbuxNh7eUMaQRZJfH27xVo3368CE)6CJkoyNbFRZZ5sHkmq068CEVaILpCNqe4oNYfIGzW(UbUZPCHWJd23nWDoLleo(Um6fCNt5sbm405GTjGhoDgw(8rfr3NGmGnHUE6C5tqcOV0hUU1hbUZPCOMNe2qPZDDZRcCNt5qnpjmH4ab35uUuylJvy)yvSjSLXkSowb1t1WUZAJTohQNQHLZAbOEQMq06COEQgl0L7cxmwfBDUUCx4TXkTXTUpITopNl6JMORZJ2bIANRhDwBS156hpRf0(6(vDFA7yRZZ5qnppw5mdeTopNlf1Dg6el)BNBA)R3()Zx2zStF7LJh(Yx3F5h)885tp9LN2nV)6YpOvp99LKN3F5Wo)0R)6WQVXtK(gpxEP)i9DJEA5H915)D)RhVT8Rh(XoWnDDHFC(2ppFA)1BZxE)F(Vl7FB(90ZPE6TK8pd" },
	},
	scarletmonastery_library = {
		{ name = "Default", exportString = "" },
	},
	scarletmonastery_armory = {
		{ name = "Default", exportString = "" },
	},
	scarletmonastery_cathedral = {
		{ name = "Default", exportString = "" },
	},
	razorfendowns = {
		{ name = "Default", exportString = "" },
	},
	uldaman = {
		{ name = "Default", exportString = "" },
	},
	zulfarrak = {
		{ name = "Default", exportString = "" },
	},
	maraudon = {
		{ name = "Default", exportString = "" },
	},
	sunkentemple = {
		{ name = "Default", exportString = "" },
	},
	blackrockdepths = {
		{ name = "Default", exportString = "" },
	},
	lowerblackrockspire = {
		{ name = "Default", exportString = "" },
	},
	upperblackrockspire = {
		{ name = "Default", exportString = "" },
	},
	diremaul_north = {
		{ name = "Default", exportString = "" },
	},
	diremaul_west = {
		{ name = "Default", exportString = "" },
	},
	diremaul_east = {
		{ name = "Default", exportString = "" },
	},
	scholomance = {
		{ name = "Default", exportString = "" },
	},
	stratholme = {
		{ name = "Default", exportString = "" },
	},
	roadtodeotherside = {
		{ name = "Default", exportString = "" },
	},
	vaultsoftheinquisition = {
		{ name = "Default", exportString = "" },
	},
	moltencore = {
		{ name = "Default", exportString = "" },
	},
	onyxialair = {
		{ name = "Default", exportString = "" },
	},
	blackwinglair = {
		{ name = "Default", exportString = "" },
	},
	zulgurub = {
		{ name = "Default", exportString = "" },
	},
	ruinsofahnqiraj = {
		{ name = "Default", exportString = "" },
	},
	templeofahnqiraj = {
		{ name = "Default", exportString = "" },
	},

	hellfireramparts = {
		{ name = "Default", exportString = "" },
	},
	bloodfurnace = {
		{ name = "Default", exportString = "" },
	},
	shatteredhalls = {
		{ name = "Default", exportString = "" },
	},
	slavepens = {
		{ name = "Default", exportString = "" },
	},
	underbog = {
		{ name = "Default", exportString = "" },
	},
	steamvault = {
		{ name = "Default", exportString = "" },
	},
	manatombs = {
		{ name = "Default", exportString = "" },
	},
	auchenaicrypts = {
		{ name = "Default", exportString = "" },
	},
	sethekkhalls = {
		{ name = "Default", exportString = "" },
	},
	shadowlabyrinth = {
		{ name = "Default", exportString = "" },
	},
	oldhillsbrad = {
		{ name = "Default", exportString = "" },
	},
	blackmorass = {
		{ name = "Default", exportString = "" },
	},
	magistersterrace = {
		{ name = "Default", exportString = "" },
	},
	themechanar = {
		{ name = "Default", exportString = "" },
	},
	thebotanica = {
		{ name = "Default", exportString = "" },
	},
	thearcatraz = {
		{ name = "Default", exportString = "" },
	},
	karazhan = {
		{ name = "Default", exportString = "" },
	},
	gruulslair = {
		{ name = "Default", exportString = "" },
	},
	magtheridonslair = {
		{ name = "Default", exportString = "" },
	},
	serpentshrinecavern = {
		{ name = "Default", exportString = "" },
	},
	tempestkeep = {
		{ name = "Default", exportString = "" },
	},
	mounthyjal = {
		{ name = "Default", exportString = "" },
	},
	blacktemple = {
		{ name = "Default", exportString = "" },
	},
	zulaman = {
		{ name = "Default", exportString = "" },
	},
	sunwellplateau = {
		{ name = "Default", exportString = "" },
	},

	utgardekeep = {
		{ name = "Default", exportString = "" },
	},
	thenexus = {
		{ name = "Default", exportString = "" },
	},
	azjolnerub = {
		{ name = "Default", exportString = "" },
	},
	ahnkahet = {
		{ name = "Default", exportString = "" },
	},
	draktharonkeep = {
		{ name = "Default", exportString = "" },
	},
	violethold = {
		{ name = "Default", exportString = "" },
	},
	gundrak = {
		{ name = "Default", exportString = "" },
	},
	hallsofstone = {
		{ name = "Default", exportString = "" },
	},
	hallsoflightning = {
		{ name = "Default", exportString = "" },
	},
	theoculus = {
		{ name = "Default", exportString = "" },
	},
	utgardepinnacle = {
		{ name = "Default", exportString = "" },
	},
	trialofthechampion = {
		{ name = "Default", exportString = "" },
	},
	forgeofsouls = {
		{ name = "Default", exportString = "" },
	},
	pitofsaron = {
		{ name = "Default", exportString = "" },
	},
	hallsofreflection = {
		{ name = "Default", exportString = "" },
	},
	cullingofstratholme = {
		{ name = "Default", exportString = "" },
	},
	naxxramas = {
		{ name = "Default", exportString = "" },
	},
	obsidiansanctum = {
		{ name = "Default", exportString = "" },
	},
	eyeofeternity = {
		{ name = "Default", exportString = "" },
	},
	ulduar = {
		{ name = "Default", exportString = "" },
	},
	trialofthecrusader = {
		{ name = "Default", exportString = "" },
	},
	icecrowncitadel = {
		{ name = "Default", exportString = "" },
	},
	rubysanctum = {
		{ name = "Default", exportString = "" },
	},
}
